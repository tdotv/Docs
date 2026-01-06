# Restore Backup with Minio (Minio <----> Local)

Instructions for restoring `bucket`s using Minio `mirror` features.

## Install Minio Client

**Install Link**
[install link](https://min.io/docs/minio/linux/reference/minio-mc-admin.html#installation)


**Linux AMD64 DEB:**
```bash
wget https://dl.min.io/client/mc/release/linux-amd64/mcli_20240722200249.0.0_amd64.deb
sudo dpkg -i mcli_20240722200249.0.0_amd64.deb
```

## Add minio server to minio alias:
```bash
mcli alias set myminio/ MINIO_SERVER_URL MINIO_ADMIN_USERNAME MINIO_ADMIN_PASSWORD
```

## Commands:

### List all contents of BUCKET_NAME
```bash
mcli ls myminio/BUCKET_NAME
```
### Backup to local
```bash
mcli mirror myminio/BUCKET_NAME path-to-your-local-backup-folder/BUCKET_NAME --overwrite
```

### Restore from local
```bash
mcli mirror path-to-your-local-backup-folder/BUCKET_NAME myminio/BUCKET_NAME --overwrite
```
