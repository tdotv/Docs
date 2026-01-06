#!/bin/bash

LOG_FILE="/var/log/docnode/deploy.log"
PROJECT_DIR=""
ARCHIVE_DIR="$PROJECT_DIR/delievery"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log() {
    local COLOR=$1
    local MESSAGE=$2
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${COLOR}${MESSAGE}${NC}" >> $LOG_FILE
    echo -e "${COLOR}${MESSAGE}${NC}"
}

confirm_action() {
    local MESSAGE=$1
    while true; do
        read -p "$MESSAGE (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Enter y - for confirmation OR n - for deny";;
        esac
    done
}

#   ================== Archives ==================

load_archives() {
    if confirm_action "Do you want to download archives from cloud.solit.by?"; then
        FILE_URLS=(
            "https://mirror.solit.by/docnode/api.tar"
            "https://cloud.solit.by/s/5WgjoEtA49HaKDJ/download/converter.zip"
            "https://mirror.solit.by/docnode/front.tar"
            "https://cloud.solit.by/s/EYrCBj5jZx5Kjot/download/pg_hbelt.so"
            "https://mirror.solit.by/docnode/sign.tar"
            "https://mirror.solit.by/docnode/verapd.tar"
        )

        SYMBOL_DOWNLOAD=">"
        SYMBOL_SUCCESS="+"
        SYMBOL_FAIL="-"

        draw_progress_bar() {
            local width=50
            local percent=$1
            local filled=$((width * percent / 100))
            local empty=$((width - filled))
            printf "["
            printf "%${filled}s" | tr ' ' '='
            printf "%${empty}s" | tr ' ' ' '
            printf "] %3d%%\r" "$percent"
        }

        for FILE_URL in "${FILE_URLS[@]}"; do
            FILE_NAME=$(basename "$FILE_URL")
            FILE_PATH="$ARCHIVE_DIR/$FILE_NAME"

            if [ -f "$FILE_PATH" ]; then
                rm -f "$FILE_PATH"
            fi

            log $YELLOW " $SYMBOL_DOWNLOAD Downloading $FILE_NAME from cloud.solit.by..."

            wget --no-check-certificate -q -P "$ARCHIVE_DIR" "$FILE_URL" &
            WGET_PID=$!

            while ps -p $WGET_PID > /dev/null; do
                for i in {0..100..10}; do
                    draw_progress_bar $i
                    sleep 0.1
                done
            done

            draw_progress_bar 100
            echo ""

            if wait $WGET_PID; then
                log $GREEN " $SYMBOL_SUCCESS $FILE_NAME has been downloaded successfully."
                echo ""
            else
                log $RED " $SYMBOL_FAIL Failed to download $FILE_NAME!"
            fi
        done

        log $GREEN " All files have been downloaded to $ARCHIVE_DIR."
    else
        log $YELLOW " Download is canceled."
    fi
}

#   ================== Docker ==================

check_containers() {
    local ALL_RUNNING=true
    for CONTAINER in $(docker compose -f "$DOCKER_COMPOSE_PATH" ps -q); do
        CONTAINER_NAME=$(docker inspect --format '{{.Name}}' $CONTAINER | sed 's/^\///')
        CONTAINER_STATE=$(docker inspect --format '{{.State.Status}}' $CONTAINER)
        if [ "$CONTAINER_STATE" != "running" ]; then
            log $YELLOW "Container $CONTAINER_NAME not running. Current state: $CONTAINER_STATE."
            ALL_RUNNING=false
        fi
    done
    $ALL_RUNNING
}

update_docker() {
        if confirm_action "Do you want to update Docker images?"; then
            log $YELLOW "Updating Docker images..."
            for IMAGE in api front sign verapd; do
                docker load -i "$ARCHIVE_DIR/$IMAGE.tar"
                if [ $? -eq 0 ]; then
                    log $GREEN "Image $IMAGE has updated successfully"
                else
                    log $RED "!!! Can't update $IMAGE !!!"
                    exit 1
                fi
            done
        else
            log $YELLOW "Docker images update is canceled"
        fi

        while true; do
            echo ""
            echo "┌────────────────────────────────────────────────────┐"
            echo "│ Enter Docker Compose file path:                    │"
            echo "│ (укажите полный путь, включая имя файла)           │"
            echo "└────────────────────────────────────────────────────┘"
            echo -n "> "
            read DOCKER_COMPOSE_PATH

            if [ ! -f "$DOCKER_COMPOSE_PATH" ]; then
                log $RED "File is not found: $DOCKER_COMPOSE_PATH"
                log $YELLOW "Re-entry Docker Compose file path"
                continue
            fi

            if confirm_action "You entered: $DOCKER_COMPOSE_PATH. Is it correct?"; then
                break
            else
                log $YELLOW "Re-entry Docker Compose file path"
            fi
        done

        echo ""
        log $YELLOW "Starting $DOCKER_COMPOSE_PATH..."
        docker compose -f "$DOCKER_COMPOSE_PATH" up -d
        if [ $? -eq 0 ]; then
            log $GREEN "Docker Compose has started succesfully"
        else
            log $RED "!!! Can't up Docker Compose !!!"
            exit 1
        fi
}

inspect_errors() {
    log $YELLOW "Waiting for containers..."
    while ! check_containers; do
        log $YELLOW "Containers have not started yet. Trying again after 5 seconds..."
        sleep 5
    done
    log $GREEN "Containers have started successfully"

    log $YELLOW "Looking errors in logs..."
    ERRORS_FOUND=0
    for CONTAINER in $(docker compose -f "$DOCKER_COMPOSE_PATH" ps -q); do
        CONTAINER_NAME=$(docker inspect --format '{{.Name}}' $CONTAINER | sed 's/^\///')
        log $GREEN "Logs $CONTAINER_NAME..."
        docker logs $CONTAINER > /tmp/container_logs.txt 2>&1
        if grep -i "error" /tmp/container_logs.txt; then
            log $RED "Found errors in  $CONTAINER_NAME:"
            cat /tmp/container_logs.txt >> $LOG_FILE
            ERRORS_FOUND=1
        else
            log $GREEN "There are no errors in $CONTAINER_NAME"
        fi
    done

    if [ $ERRORS_FOUND -eq 1 ]; then
        log $RED "Check logs in $LOG_FILE"
    else
        log $GREEN "There are no errors"
    fi
}

#   ================== PostgreSQL ==================

get_docker_interface_ip() {
    local ip_address

    DOCKER_INTERFACES=$(ip -o link show | awk -F': ' '/br-|docker0/ {print $2}')

    if [ -z "$DOCKER_INTERFACES" ]; then
        log $RED "!!! Could not find any Docker network interfaces !!!" >&2
        exit 1
    fi

    for interface in $DOCKER_INTERFACES; do
        if ! ip -o link show "$interface" > /dev/null 2>&1; then
            log $YELLOW "Interface $interface does not exist, skipping..." >&2
            continue
        fi

        interface_state=$(ip -o link show "$interface" | awk '{print $9}')
        if [ "$interface_state" != "UP" ]; then
            log $YELLOW "Interface $interface is not UP, skipping..." >&2
            continue
        fi

        ip_address=$(ip -4 addr show "$interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        if [ -n "$ip_address" ]; then
            log $GREEN "Found active Docker interface: $interface with IP: $ip_address" >&2
            echo "$ip_address"
            return
        fi
    done

    log $RED "!!! Could not determine Docker interface IP address (no active interfaces) !!!" >&2
    exit 1
}

update_postgresql_conf() {
    local ip_address=$1
    local postgresql_conf_path="/etc/postgresql/15/main/postgresql.conf"

    echo ""
    log $YELLOW "📄 Updating PostgreSQL configuration (postgresql.conf)..."

    if [ ! -f "$postgresql_conf_path" ]; then
        log $RED "!!! postgresql.conf not found at $postgresql_conf_path !!!" >&2
        exit 1
    fi

    new_listen_addresses="'localhost, $ip_address'"

    sudo sed -i "s/^#*listen_addresses\s*=\s*.*/listen_addresses = $new_listen_addresses/" "$postgresql_conf_path"
    log $GREEN "   PostgreSQL configuration updated: listen_addresses = $new_listen_addresses" >&2
}

update_pg_hba_conf() {
    local ip_address=$1
    local pg_hba_conf_path="/etc/postgresql/15/main/pg_hba.conf"

    echo ""
    log $YELLOW "🔑 Updating pg_hba configuration (pg_hba.conf)..."

    if [ ! -f "$pg_hba_conf_path" ]; then
        log $RED "!!! pg_hba.conf not found at $pg_hba_conf_path !!!" >&2
        exit 1
    fi

    echo "host    all             all             $ip_address/8            md5" | sudo tee -a "$pg_hba_conf_path" > /dev/null
    log $GREEN "   pg_hba.conf updated with IP: $ip_address" >&2
}

update_env_file() {
    local ip_address=$1
    local env_file=".env"

    echo ""
    log $YELLOW "⚙️  Updating .env file..."

    if [ ! -f "$env_file" ]; then
        log $RED "!!! .env file not found !!!" >&2
        exit 1
    fi

    log $YELLOW " Updating DB_HOST and FILE_STORAGE_HOST with Docker IP: $ip_address..." >&2

    sed -i "s/^DB_HOST=.*/DB_HOST=$ip_address/" "$env_file"
    sed -i "s/^FILE_STORAGE_HOST=.*/FILE_STORAGE_HOST=$ip_address/" "$env_file"

    if [ $? -eq 0 ]; then
        log $GREEN "   .env file updated successfully." >&2
    else
        log $RED "!!! Failed to update .env file !!!" >&2
        exit 1
    fi
}

setup_postgresql() {
    DOCKER_IP=$(get_docker_interface_ip)
    log $YELLOW "Detected Docker interface IP: $DOCKER_IP"

    update_postgresql_conf "$DOCKER_IP"
    update_pg_hba_conf "$DOCKER_IP"
    update_env_file "$DOCKER_IP"

    echo ""
    log $YELLOW "Restarting PostgreSQL to apply changes..."
    sudo systemctl restart postgresql
    if [ $? -eq 0 ]; then
        log $GREEN "PostgreSQL restarted successfully"
    else
        log $RED "!!! Failed to restart PostgreSQL !!!"
        exit 1
    fi
}

#   ================== Main ==================

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
log $GREEN "Log file is created: $LOG_FILE"
mkdir -p $ARCHIVE_DIR
log $GREEN "Archives directory is created: $ARCHIVE_DIR"

if ! command -v docker &> /dev/null; then
    log $RED "!!! Docker is not installed !!!"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    log $RED "Docker Compose not available. Be sure Docker is version 20.10.0 (or higher)"
    exit 1
fi

while true; do
    echo ""
    echo "---------------------"
    echo "1) Download archives      |   use apt-get update before that"
    echo "2) Update docker images   |   docker compose up"
    echo "3) Inspect errors         |   works after 2) Update docker images"
    echo "4) PostgreSQL setup       |   postgresql.conf && pg_hba && .env"
    echo "5) Exit"
    read -p "Choose your action: " choice

    case $choice in
        1)
            echo ""
            load_archives
            ;;
        2)
            echo ""
            update_docker
            ;;
        3)
            echo ""
            inspect_errors
            ;;
        4)
            echo ""
            setup_postgresql
            ;;
        5)
            echo ""
            log $GREEN "Deploy is finished!"
            echo ""
            break
            ;;
        *)
            echo ""
            log $RED "Wrong choise. Please choose 1 ... 5!"
            ;;
    esac
done