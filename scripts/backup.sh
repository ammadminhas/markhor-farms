#!/bin/bash

# Markhor Farms - Backup Script
# This script backs up the database and files

set -e

# Configuration
BACKUP_DIR="/backups"
FILES_DIR="/backup/files"
POSTGRES_DIR="/backup/postgres"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"
DB_BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql"
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}

# Logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "${BACKUP_DIR}/backup.log"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

log "Starting backup process..."

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Database backup
if [ -z "${DB_HOST}" ] || [ -z "${DB_USER}" ] || [ -z "${DB_NAME}" ]; then
    error_exit "Database configuration missing (DB_HOST, DB_USER, DB_NAME required)"
fi

log "Backing up PostgreSQL database: ${DB_NAME}..."
PGPASSWORD="${DB_PASSWORD}" pg_dump \
    -h "${DB_HOST}" \
    -U "${DB_USER}" \
    -d "${DB_NAME}" \
    --format=plain \
    --verbose \
    > "${DB_BACKUP_FILE}" 2>> "${BACKUP_DIR}/backup.log" || error_exit "Database backup failed"

log "Database backup completed: ${DB_BACKUP_FILE}"

# Files backup
if [ -d "${FILES_DIR}" ]; then
    log "Backing up files directory..."
    tar -czf "${BACKUP_FILE}" \
        -C "${BACKUP_DIR}" \
        --exclude='*.tar.gz' \
        . || error_exit "Files backup failed"
    log "Files backup completed: ${BACKUP_FILE}"
else
    log "WARNING: Files directory not found at ${FILES_DIR}, skipping files backup"
fi

# S3 upload (if configured)
if [ -n "${S3_BUCKET}" ] && [ -n "${S3_ACCESS_KEY}" ] && [ -n "${S3_SECRET_KEY}" ]; then
    log "Uploading backups to S3 bucket: ${S3_BUCKET}..."

    export AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY}"
    export AWS_SECRET_ACCESS_KEY="${S3_SECRET_KEY}"
    export AWS_DEFAULT_REGION="${S3_REGION:-us-east-1}"

    # Upload database backup
    aws s3 cp "${DB_BACKUP_FILE}" \
        "s3://${S3_BUCKET}/markhor-farms/db_backups/" \
        --sse AES256 \
        || log "WARNING: S3 database backup upload failed"

    # Upload files backup
    if [ -f "${BACKUP_FILE}" ]; then
        aws s3 cp "${BACKUP_FILE}" \
            "s3://${S3_BUCKET}/markhor-farms/file_backups/" \
            --sse AES256 \
            || log "WARNING: S3 files backup upload failed"
    fi

    log "S3 upload completed"
fi

# Cleanup old backups
log "Cleaning up backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -maxdepth 1 -type f -name "*.sql" -mtime +${RETENTION_DAYS} -delete || true
find "${BACKUP_DIR}" -maxdepth 1 -type f -name "*.tar.gz" -mtime +${RETENTION_DAYS} -delete || true

# Record last backup timestamp
date > "${BACKUP_DIR}/last-backup-timestamp"

log "Backup process completed successfully"
log "Backup files: ${DB_BACKUP_FILE}"
[ -f "${BACKUP_FILE}" ] && log "Backup files: ${BACKUP_FILE}"
