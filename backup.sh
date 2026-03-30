#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DIR/tools.sh"

# Load Credentials
if [ -f .env ]; then
    source "$DIR/.env"
else
    echo "File .env not found"
    exit 1
fi

if [ -z "$BACKUPS_DIR" ]; then
    BACKUPS_DIR=/opt/backups/
    print_warning "BACKUPS_DIR not found in .env file, '$BACKUPS_DIR' is going to be used"
fi


if [ ! -d "$BACKUPS_DIR" ]; then
    echo "Bakcups Dir do not exists, creating dir..."
    mkdir "$BACKUPS_DIR"
fi

DATE=$(date "+%Y-%m-%d_%H-%M-%S")

export PGPASSWORD="$DB_PASSWORD"
FILEPATH="${BACKUPS_DIR%/}/$DB_NAME-$DATE.dump"

# BACKUP

if pg_dump -U "$DB_USER" -h "$DB_HOST" -Fc "$DB_NAME" > "$FILEPATH"; then

    echo "Backup succesfully saved at: "
    echo "$FILEPATH"
else
    print_error "The backup failed"
    exit 1;
fi

# S3 Storage 

if [ -z "$S3_BUCKET_NAME" ] || [ -z "$S3_KEY_ID" ]; then
    print_error "S3 configuration missing in .env"
    exit 1
fi

if [ -n "$S3_PREFIX" ]; then
    S3_PATH="s3://$S3_BUCKET_NAME/$S3_PREFIX/"
else
    S3_PATH="s3://$S3_BUCKET_NAME/"
fi

export AWS_ACCESS_KEY_ID="$S3_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$S3_APP_KEY"

echo -e "Sending backup to s3 ... \n"

if aws s3 cp "$FILEPATH" "$S3_PATH" --endpoint-url="$S3_ENDPOINT" --quiet; then
    echo "Backup saved correctly in $S3_BUCKET_NAME"
else
    print_error "Error sending backup to S3"
    exit 1;
fi

if [ -n "$CLEAN_LOCAL_BACKUPS" ] && [ "$CLEAN_LOCAL_BACKUPS" == true ]; then

    echo "Deleting local backup..."
    rm -f "$FILEPATH"
else
    echo "Local backup is saved at: $FILEPATH"
fi

exit 0