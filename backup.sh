#!/bin/bash

backup_dir="/temp/backup"
worlds_directory="/data/tModLoader/Worlds"
max_files=5

if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir"
  echo "Created backup directory: $backup_dir"
fi

cd "$backup_dir"

timestamp=$(date +"%Y%m%d_%H%M%S")

tar -zcvf "Worlds_$timestamp.tar.gz" -C "$worlds_directory" .

aws s3 cp "Worlds_$timestamp.tar.gz" s3://${R2_BUCKET_NAME}/ --endpoint-url https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com

rm "Worlds_$timestamp.tar.gz"

file_list=$(aws s3 ls s3://calamine/ --endpoint-url https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com | awk '{print $4}' | sort)
file_count=$(echo "$file_list" | wc -l)

files_to_delete=$((file_count - max_files))

if [ $files_to_delete -gt 0 ]; then
  echo "Exceeds maximum files. Deleting oldest files..."

  files_to_delete_list=$(echo "$file_list" | head -n $files_to_delete)

  for file_key in $files_to_delete_list; do
    aws s3 rm s3://calamine/"$file_key" --endpoint-url https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com
  done
fi
