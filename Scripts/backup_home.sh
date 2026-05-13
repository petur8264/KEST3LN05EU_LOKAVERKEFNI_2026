#!/usr/bin/env bash

BACKUP_DIR="/backups"
DATE=$(date +%Y-%m-%d)

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/home_backup_$DATE.tar.gz" /home
echo "Backup completed: home_backup_$DATE.tar.gz"

(crontab -l 2>/dev/null; echo "0 0 * * 5 /usr/bin/bash /path/to/backup.sh") | crontab -
