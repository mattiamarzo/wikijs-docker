FROM postgres:12

# questa immagine è predisposta per eseguire automaticamente (se il db è vuoto) gli script eseguibili nella cartella /docker-entrypoint-initdb.d
# ci copio il dump del db per inizializzare il db se vuoto
COPY dump_wikijs_last.sql /docker-entrypoint-initdb.d
# rendo il dump eseguibile
RUN chmod +x /docker-entrypoint-initdb.d/dump_wikijs_last.sql

# creo la directory in cui salverò i dump periodici eseguit da cron
RUN mkdir /var/lib/postgresql/sqldumps

#### i seguenti comandi lanciati da root non agiscono su /etc/crontab ma su /var/spool/crontab/root
# aggiungo un job cron schedulato (ogni gg alle 10:00) che esegue il dump (senza "crontab -l && " perché il file non esiste e il comando andrebbe in error)
RUN (echo "00 10 * * * /bin/sh /var/lib/postgresql/sqldumps/dump_wikijs_db.sh >> /var/lib/postgresql/sqldumps/cron_dump.log 2>&1") | crontab -
# aggiungo un secondo job (ogni gg alle 21:00), la stringa "crontab -l && " serve ad andare in aggiunta, senza sovrascrivere il file
RUN (crontab -l && echo "00 21 * * * /bin/sh /var/lib/postgresql/sqldumps/dump_wikijs_db.sh >> /var/lib/postgresql/sqldumps/cron_dump.log 2>&1") | crontab -
# aggiungo un terzo job di test (ogni gg alle 15:00)
RUN (crontab -l && echo "00 15 * * * /bin/sh /var/lib/postgresql/sqldumps/dump_wikijs_db.sh >> /var/lib/postgresql/sqldumps/cron_dump.log 2>&1") | crontab -