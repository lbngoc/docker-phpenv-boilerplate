ARGS = $(filter-out $@,$(MAKECMDGOALS))

all:
	@echo "Usage: "
	@echo "  make build                           : Build project for first deploy on server."
	@echo "  make start                           : Start server in background."
	@echo "  make bash                            : Connect to virtual docker container."
	@echo "  make root                            : Connect to virtual docker container with root permission."
	@echo "  make mysql-backup                    : Backup current database to compressed file."
	@echo "  make mysql-restore [filename.sql.bz] : Restore compressed file to current database."


#############################
# MySQL
#############################

mysql-backup:
	docker-compose run --rm --no-deps main root bash /docker/bin/backup.sh mysql

mysql-restore:
	docker-compose run --rm --no-deps main root bash /docker/bin/restore.sh mysql

#############################
# Solr
#############################

# solr-backup:
# 	docker-compose stop solr
# 	docker-compose run --rm --no-deps main root bash /docker/bin/backup.sh solr
# 	docker-compose start solr

# solr-restore:
# 	docker-compose stop solr
# 	docker-compose run --rm --no-deps main root bash /docker/bin/restore.sh solr
# 	docker-compose start solr

#############################
# General
#############################

# backup:  mysql-backup  solr-backup
# restore: mysql-restore solr-restore

build:
	bash bin/build.sh

# clean:
# 	test -d code/typo3temp && { rm -rf code/typo3temp/*; }

bash:
	docker-compose run --rm main bash

root:
	docker-compose run --rm main root

#############################
# TYPO3
#############################

# scheduler:
# 	docker-compose run --rm main typo3/cli_dispatch.phpsh scheduler $(ARGS)

#############################
# Argument fix workaround
#############################
%:
	@:
