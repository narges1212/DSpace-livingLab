#!/bin/sh
set -e

export WIP_LATEST_SSOAR_BACKUP_TIMESTAMP=$(date -u +"%Y-%m-%dT%H_%M_%SZ")
export SSOAR_BACKUP_LOG_DIRECTORY="/cygdrive/i/SSOAR/backups/${WIP_LATEST_SSOAR_BACKUP_TIMESTAMP}/"
export SSOAR_BACKUP_LOG_FILE="${SSOAR_BACKUP_LOG_DIRECTORY}backup.log"

mkdir -p $SSOAR_BACKUP_LOG_DIRECTORY && touch $SSOAR_BACKUP_LOG_FILE

sh ./backup_ssoar_without_logging.sh 2>&1 | tee $SSOAR_BACKUP_LOG_FILE
