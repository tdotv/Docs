#!/bin/bash

# Скрипт для скачивания образов в архивы локально
set -e

IMAGES=(
    "gitlab.solit.by:5050/<name>:<tag> api"
    "verapdf/rest verapd"
)

mkdir -p images

for ITEM in "${IMAGES[@]}"; do
    IMAGE=$(echo "$ITEM" | awk '{print $1}')
    OUTPUT=$(echo "$ITEM" | awk '{print $2}')
    OUTPUT_FILE="images/${OUTPUT}.tar"

    # Получаем текущий digest из локального репозитория
    LOCAL_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE" 2>/dev/null || echo "")

    # Скачиваем образ, чтобы проверить его digest
    docker pull "$IMAGE" >/dev/null
    REMOTE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE")

    # Проверяем, существует ли файл
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo "Файл $OUTPUT_FILE уже существует, проверяем обновление образа..."
        
        # Сравниваем digests
        if [[ "$LOCAL_DIGEST" != "$REMOTE_DIGEST" ]]; then
            echo "Образ $IMAGE обновлен, сохраняем его в $OUTPUT_FILE"
            docker save -o "$OUTPUT_FILE" "$IMAGE"
        else
            echo "Образ $IMAGE не изменился, пропускаем сохранение"
        fi
    else
        echo "Файл $OUTPUT_FILE отсутствует, создаем его."
        docker save -o "$OUTPUT_FILE" "$IMAGE"
    fi
done
