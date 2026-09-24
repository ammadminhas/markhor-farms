#!/bin/bash

# Markhor Farms - Backup Cleanup Script
# This script removes old backup files

set -e

# Configuration
BACKUP_DIR="/backups"
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}

# Logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "${BACKUP_DIR}/cleanup.log"
}

log "Starting backup cleanup process..."

# Cleanup old SQL backups
SQL_FILES=$(find "${BACKUP_DIR}" -maxdepth 1 -type f -name "*.sql" -mtime +${RETENTION_DAYS})
if [ -n "$SQL_FILES" ]; then
    log "Removing SQL backups older than ${RETENTION_DAYS} days:"
    echo "$SQL_FILES" | while read -r file; do
        log "  Removing: $file"
        rm -f "$file"
    done
else
    log "No SQL backups to cleanup"
fi

# Cleanup old tar.gz backups
TAR_FILES=$(find "${BACKUP_DIR}" -maxdepth 1 -type f -name "*.tar.gz" -mtime +${RETENTION_DAYS})
if [ -n "$TAR_FILES" ]; then
    log "Removing tar.gz backups older than ${RETENTION_DAYS} days:"
    echo "$TAR_FILES" | while read -r file; do
        log "  Removing: $file"
        rm -f "$file"
    done
else
    log "No tar.gz backups to cleanup"
fi

# Report remaining backups
REMAINING=$(find "${BACKUP_DIR}" -maxdepth 1 -type f \( -name "*.sql" -o -name "*.tar.gz" \) | wc -l)
log "Cleanup completed. Remaining backups: ${REMAINING}"
