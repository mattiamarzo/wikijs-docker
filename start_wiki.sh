#!/bin/sh

# copio l'ultimo dump nella dir da cui viene poi copiato nel container
cp sqldumps/dump_wikijs_last.sql src_postgres/dump_wikijs_last.sql

# tiro su la stack dei containers
docker-compose up -d

# faccio partire cron all'interno del container
docker exec -it wiki_db_1 cron