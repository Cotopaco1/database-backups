This repository give bash scripts for automate database backups using postgres + s3 storage.

> Version 0.1

## Requirements
- pg_dump
- postgres running on port 5432
- aws s3 CLI

## Guide
- cp .env.example .env
- fill variables
- chmod +x backup.sh
- ./backup.sh

Thats all, enjoy your backup saved in s3 storage.