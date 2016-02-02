#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.config.sh"

if [ "$#" -ne 1 ]; then
    echo "No type defined"
    exit 1
fi

mkdir -p -- "${BACKUP_DIR}"

case "$1" in
    ###################################
    ## MySQL
    ###################################
    "mysql-all")
        if [ -f "${BACKUP_DIR}/${BACKUP_MYSQL_FILE}" ]; then
            logMsg "Removing old backup file..."
            rm -f -- "${BACKUP_DIR}/${BACKUP_MYSQL_FILE}"
        fi

        logMsg "Starting MySQL backup all databases..."
        mysqldump --opt --single-transaction --events --all-databases | bzip2 > "${BACKUP_DIR}/${BACKUP_MYSQL_FILE}"
        ;;

    "mysql")

        logMsg "Starting MySQL backup..."

        FILENAME=$MYSQL_DATABASE.$(date +%Y-%m-%d-%H.%M.%S)
        mysqldump -hmysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE | gzip -c > "$BACKUP_DIR/$FILENAME.sql.gz"
        logMsg ">> Backup file is saved at $BACKUP_DIR/$FILENAME.sql.gz"
        ;;

    ###################################
    ## Solr
    ###################################
    "solr")
        if [ -f "${BACKUP_DIR}/${BACKUP_SOLR_FILE}" ]; then
            logMsg "Removing old backup file..."
            rm -f -- "${BACKUP_DIR}/${BACKUP_SOLR_FILE}"
        fi

        logMsg "Starting Solr backup..."
        tar jcPf "${BACKUP_DIR}/${BACKUP_SOLR_FILE}" /data/solr/
        ;;
esac
