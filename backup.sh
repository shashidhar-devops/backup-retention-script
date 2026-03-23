#!/bin/bash

# Exit immediately on error, treat unset variables as errors, and catch pipe failures
set -euo pipefail

# Ensure exactly 3 arguments are passed before doing anything else
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source directory> <backup directory> <retention count>"
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"
RETENTION_LIMIT="$3"

# Validate source directory exists — can't back up something that isn't there
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist."
    exit 1
fi

# Create backup directory if it doesn't exist yet
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Retention limit must be a positive integer — reject anything else
if [[ ! "$RETENTION_LIMIT" =~ ^[0-9]+$ ]]; then
    echo "Need a numeric value..."
    exit 1
fi

# Generate a timestamp-based filename to avoid collisions and make versioning clear
DATE=$(date '+%Y%m%d_%H%M%S')
backup_file="backup_${DATE}.tar.gz"

# Create a compressed archive of the source directory
tar -czf "$BACKUP_DIR/$backup_file" "$SOURCE_DIR"

# Log the name of the backup file that was just created
echo "$backup_file" > /home/user/answer.txt

# Count how many backup archives currently exist in the backup directory
backup_count=$(ls "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | wc -l)

if [[ "$backup_count" -gt "$RETENTION_LIMIT" ]]; then
    # Calculate how many excess backups need to be removed
    d_c=$(("$backup_count" - "$RETENTION_LIMIT"))

    # ls -rt sorts by modification time, oldest first — so head picks the oldest N files
    # This ensures we never accidentally delete the most recent backups
    ls -rt "$BACKUP_DIR"/backup_*.tar.gz | head -"$d_c" | xargs rm -rf

    echo "DELETED:$d_c" >> /home/user/answer.txt
else
    echo "DELETED:0" >> /home/user/answer.txt
fi

# Count and log how many backups remain after the cleanup
remain=$(ls "$BACKUP_DIR"/backup_*.tar.gz | wc -l)
echo "REMAINING:$remain" >> /home/user/answer.txt
