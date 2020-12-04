#!/bin/sh
cd /var/lib/postgresql/sqldumps

# eseguo i ldump creando un file con la data di oggi
pg_dump -U wikijs wikijs > dump_wikijs_$(date +'%Y%m%d').sql

# copio il dump di oggi in un file "last" pronto per essere prelevato dallo script che builda il container se il db è vuoto
cp dump_wikijs_$(date +'%Y%m%d').sql dump_wikijs_last.sql