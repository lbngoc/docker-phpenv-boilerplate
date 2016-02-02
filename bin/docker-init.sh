#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

# source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.config.sh"

#######################################
## Functions
#######################################

errorMsg() {
    echo "[ERROR] $*"
}

logMsg() {
    echo " * $*"
}

printMsg() {
    printf " * $*"
}

sectionHeader() {
    echo "*** $* ***"
}

execInDir() {
    echo "[RUN :: $1] $2"

    sh -c "cd \"$1\" && $2"
}

#######################################
## Begin
#######################################

printMsg "Are you sure to init docker here [y/n]? " && read CONTINUE
if [[ ! $CONTINUE =~ ^[Yy]$ ]]
then
    exit 1
fi

# CURRENT_PATH=$(pwd)
# SOURCE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd )"

# Move all current source code to source folder
# if [[ ! $CURRENT_PATH = $SOURCE_PATH ]]; then
    mkdir -p -- source
    ALLFILES=$(ls -A --ignore=source)
    mv -f --backup=numbered $ALLFILES source/
    # cp -rf $SOURCE_PATH/* .
# fi

# Download all source file to current folder
wget -O dockerenv.zip https://github.com/lbngoc/docker-phpenv-boilerplate/archive/master.zip && unzip dockerenv.zip && rm dockerenv.zip

# Get input settings from user
while [[ ! $PROJECT_NAME =~ ^[A-Za-z0-9-]+$ ]]; do
    printMsg ">> Enter project name [a-zA-Z0-9-]: " && read PROJECT_NAME
done

while [[ ! $PROJECT_ROOT =~ ^[A-Za-z0-9-]+$ ]]; do
    printMsg ">> Enter project root path (./source/) [a-zA-Z0-9-]: " && read PROJECT_ROOT
done

while [[ ! $PROJECT_PORT =~ ^[1-9][0-9]{3,4}$ ]]; do
    printMsg ">> Enter docker application port [1000~99999]: " && read PROJECT_PORT
done

while [[ ! $PROJECT_DBNAME =~ ^[A-Za-z0-9-]+$ ]]; do
    printMsg ">> Enter database name [a-zA-Z0-9-]: " && read PROJECT_DBNAME
done

# Change docker settings
mv project.sublime-project $PROJECT_NAME.sublime-project
cp docker-compose.yml
sed -i "s/- 9999:/- $PROJECT_PORT:/g" docker-compose.yml
sed -i "s/DOCUMENT_ROOT=source/DOCUMENT_ROOT=$PROJECT_ROOT/" docker-env.yml
sed -i "s/database_name_here/$PROJECT_DBNAME/g" docker-env.yml

logMsg "================ Docker is initialized ! ====================="
logMsg "  - edit \"docker-compose.yml\" if you want to change docker settings."
logMsg "  - type \"make\" for get helps to run project with docker."



