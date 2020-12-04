#!/bin/sh
# tiro giù lo stack dei containers
docker-compose down

# elimino volumi ed immagini (nomi validi se la creazione del container viene lanciata da una cartella chiamata "wiki"
# questa pulizia fa sì che al successivo "up" i container vengano buildati da zero e il db reinizializzato con l'ultimo dump
docker volume rm wiki_wikijs_data wiki_wikijs_db
docker rmi wiki_wiki:latest wiki_db:latest