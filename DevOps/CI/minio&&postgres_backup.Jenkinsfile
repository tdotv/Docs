pipeline {
    agent any

    environment {
        REMOTE_HOST         = ""
        BASE_BACKUP_DIR     = ""
        POSTGRES_DUMP_DIR   = "${BASE_BACKUP_DIR}/postgres_dump"
        MINIO_MIRROR_DIR    = "${BASE_BACKUP_DIR}/minio_mirror"
        MINIO_URL           = ""
        MINIO_BUCKET        = ""
        POSTGRES_USER       = ""
    }

    // parameters {
    //     string(name: 'REMOTE_HOST', defaultValue: '192.168.12.5', description: 'PostgreSQL host')
    //     string(name: 'POSTGRES_USER', defaultValue: 'postgres', description: 'PostgreSQL user')
    // }

    stages {
        stage('Setup and Check') {
            steps {
                sh """
                    mkdir -p ${MINIO_MIRROR_DIR}
                    mkdir -p ${POSTGRES_DUMP_DIR}
                    pg_isready -h ${REMOTE_HOST} -U ${POSTGRES_USER} || { echo "PostgreSQL not ready"; exit 1; }
                """
            }
        }

        stage('Create PostgreSQL Dump') {
            steps {
                withCredentials([string(credentialsId: 'PGPASSWORD', variable: 'PGPASSWORD')]) {
                    script {
                        def DATE = sh(script: 'date +%Y-%m-%d', returnStdout: true).trim()
                        def PG_DUMP_FILE = "${POSTGRES_DUMP_DIR}/dump-${DATE}.sql"
                        sh """
                            PGPASSWORD="$PGPASSWORD" /usr/lib/postgresql/15/bin/pg_dumpall -h ${REMOTE_HOST} -U ${POSTGRES_USER} -f ${PG_DUMP_FILE}
                        """
                    }
                }
            }
        }

        stage('Clean Old Dumps') {
            steps {
                script {
                    sh """
                        find ${POSTGRES_DUMP_DIR} -maxdepth 1 -type f -name 'dump-*.sql' -mtime +2 -delete
                    """
                }
            }
        }

        // stage('Create PostgreSQL Base Backup') {
        //     steps {
        //         withCredentials([string(credentialsId: 'PGPASSWORD', variable: 'PGPASSWORD')]) {
        //             sh """
        //                 PGPASSWORD="$PGPASSWORD" /usr/lib/postgresql/15/bin/pg_basebackup -D ${PG_BASEBACKUP_DIR} -h ${REMOTE_HOST} -U ${POSTGRES_USER} -Fp -Xs -P -v
        //             """
        //         }
        //     }
        // }

        stage('Create MinIO Backup') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'MINIOPASSWORD', variable: 'MINIOPASSWORD')]) {
                        sh """
                            export PATH=$PATH:$HOME/minio-binaries/
                            if ! mc alias ls --json | jq -e '.alias | select(.=="${MINIO_BUCKET}")' > /dev/null; then
                                echo "Alias '${MINIO_BUCKET}' not found! Creating..."
                                mc alias set ${MINIO_BUCKET} ${MINIO_URL} minioadmin ${MINIOPASSWORD} || exit 1
                            fi
                            mc ls ${MINIO_BUCKET}
                            mc du ${MINIO_BUCKET}
                            mc mirror ${MINIO_BUCKET} ${MINIO_MIRROR_DIR} --remove
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Backup completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}