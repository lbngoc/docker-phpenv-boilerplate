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
            logMsg "Starting MySQL restore..."
            bzcat "${BACKUP_DIR}/${BACKUP_MYSQL_FILE}" | mysql
        else
            errorMsg "MySQL backup file not found"
            exit 1
        fi
        ;;

    "mysql")
        logMsg "=== Exported SQL Files ==="
        ls $BACKUP_DIR | grep 'sql.gz'
        logMsg "=========================="
        printMsg ">> Enter file name: " && read FILENAME

        if [ ! -f "$BACKUP_DIR/$FILENAME" ]; then
            logMsg ">> File does not exits."
            exit 1
        fi

        gunzip < $BACKUP_DIR/$FILENAME | mysql -hmysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

        logMsg ">> File $BACKUP_DIR/$FILENAME.sql.gz is imported."
        ;;

    ###################################
    ## Solr
    ###################################
    "solr")
        if [ -f "${BACKUP_DIR}/${BACKUP_SOLR_FILE}" ]; then
            logMsg "Starting Solr restore..."
            rm -rf /data/solr/* && mkdir -p /data/solr/
            chmod 777 /data/solr/
            tar jxPf "${BACKUP_DIR}/${BACKUP_SOLR_FILE}" -C /
        else
            errorMsg "Solr backup file not found"
            exit 1
        fi
        ;;
esac
