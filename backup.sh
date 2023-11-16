#!/bin/bash

backup_dir="/temp/backup"
worlds_directory="/data/tModLoader/Worlds"
max_files=5

if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir"
  echo "Created backup directory: $backup_dir"
fi

echo "Starting backup process..."

cd "$backup_dir"

timestamp=$(date +"%Y%m%d_%H%M%S")
echo "Timestamp for backup: $timestamp"

echo "Compressing worlds directory..."

tar -zcvf "Worlds_$timestamp.tar.gz" -C "$worlds_directory" .
echo "Backup file created: Worlds_$timestamp.tar.gz"

echo "Uploading backup to S3..."
aws s3 cp "Worlds_$timestamp.tar.gz" s3://${R2_BUCKET_NAME}/ --endpoint-url https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com
echo "Backup uploaded to S3"

echo "Cleaning up temporary backup file..."
rm "Worlds_$timestamp.tar.gz"
echo "Temporary backup file removed"

echo "Checking existing backup files in S3..."

file_list=$(aws s3 ls s3://calamine/ --endpoint-url https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com | awk '{print $4}' | sort)
file_count=$(echo "$file_list" | wc -l)

echo "Number of existing backup files: $file_count"

files_to_delete=$((file_count - max_files))

if [ $files_to_delete -gt 0 ]; then
  echo "Exceeds maximum files. Deleting oldest files..."

  files_to_delete_list=$(echo "$file_list" | head -n $files_to_delete)

  for file_key in $files_to_delete_list; do
    aws s3 rm s3://calamine/"$file_key" --endpoint-url https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com
    echo "Deleted old backup file: $file_key"
  done
fi

echo "Backup process completed."
