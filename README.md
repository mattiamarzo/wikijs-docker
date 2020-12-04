# WikiDocker

Questo Readme contiene:
- istruzioni su come deployare il wiki su qualsiasi macchina Linux (tested: Debian) su cui sono installati Docker e Docker-Compose
- spiegazione del contenuto, logiche di funzionamento etc


## Intro
In questo repository c'è tutto il necessario per deployare, con un singolo comando, una web-app che rende fruibile un'istanza del software wiki "[WikiJS](https://wiki.js.org/)".
I due container vengono buildati a partire da:
- immagine docker ufficiale di WIkiJS, versione 2.1
- immagine docker ufficiale di Postgres, con diverse customizzazioni


## Deploy rapido
1. Recuperare il software
- come package disponibile nelle release del progetto (stable)
- oppure clonando il repository, se si vuole deployare il commit più recente (unstable)
2. Posizionarsi nella root del progetto. Deve chiamarsi "wiki" perché i comandi di pulizia contenuti in `stop_wiki_cleanAll.sh` funzionino adeguatamente.

3. Assicurarsi che nella cartella /src_postgres sia presente il file "dump_wikijs_last.sql".
Dev'essere un dump PostgreSQL in formato **plain**.
Se manca, la build va in errore.
Se si desidera un'installazione pulita al momento l'unico modo è fornire un dump vuoto. In futuro verrà realizzato apposito script sh.

4. Da riga di comando lanciare il comando:
`./start_wiki.sh`
Necessario lanciarlo con privilegi di root o sudo (perché esegue docker e crontab).

5. Nella cartella /sqldumps vengono salvati, 3 volte al giorno, i dump del db. Ogni dump sovrascrive quelli creati lo stesso giorno, se presenti.
Questa directory va opportunamente gestita per evitare che aumenti eccessivamente di dimensioni.


## Composizione del package
### docker-compose.yaml
Il file guida di docker-compose.
Definisce i due servizi (uno per container) che compongono lo stack (app + db).
Definisce inoltre i due volumi, necessari per assicurare la persistenza dei dati.
Inoltre per ciascuno dei due servizi indica la directory che costituisce il "build context", contenente Dockerfile e gli altri files necessari al processo di build.  
**Importante**: se non si utlizzia un reverse proxy è necessario modificare l'indirzzo di ascolto da `127.0.0.0` a `0.0.0.0` (direttiva "ports" del container "wiki")
**Importante 2**: è qui che viene definita la porta dell'host su cui è in ascolto il wiki.
**Importante 3**: se si vuole raggiungere direttamente il db da remoto è necessario mappare la porta del container su una porta dell'host


### shell
- start_wiki.sh
	1. copia nel build context del db l'ultimo dump disponibile
	2. lancia il comando `docker-compose up -d`
		(start dello stack in background)
	4. quando lo stack è up&running lancia cron
- stop_wiki.sh
	1. Stoppa lo stack. Ciò causa la rimozione dei container (non dei volumi).
- stop_wiki_cleanAll.sh
	1. Stoppa lo stack, e contestualmente rimuove tutti i volumi e le immagini buildate relativi ai due container.
		Così facendo lanciare di nuovo "start_wiki.sh" comporta che venga rieseguita la build e l'inizializzazione del db col dump.


### variables.env
Contiene le variabili d'ambiente passate a docker-engine durante la build.
Info sulle variabili sono definiti nella documentazione ufficiale delle immagini docker:
- WikijS: [Doc ufficiale](https://docs.requarks.io/install/docker) / [ pagina DockerHub](https://hub.docker.com/r/requarks/wiki)
- Postgres: [Pagina progetto ufficiale](https://github.com/docker-library/postgres) / [pagina DockerHub](https://hub.docker.com/_/postgres)
Se si vogliono modificare le utenze postgres di default è possible farlo qui, prestando attenzione a passare sia a wikijs che a postgres le stesse credenziali e configurazioni.


### wikijs_nginx.conf
Un utile template di configurazione, testato e funzionante su nginx/1.14.2, per mettere wikijs dietro un reverse proxy.
Questo specifico esempio è configurato per
- reindirizzare tutto il traffico su https
- predisposto per fornire ad nginx i certificati SSL
- essere in ascolto solo su uno specifico (configurabile) dominio del tipo wiki.domin.io
Se non si utilizza un reverse proxy è necessario:
- ignorare questo file
- modificare l'indirizzo di ascolto in docker-compose.yaml (vd. sopra)
Così il wiki sarà raggiungibile sulla porta 3000 dell'host.


### sqldumps/
La cartella /sqldumps verrà mappata all'interno del container al path /var/lib/postgres/sqldumps.
Contiene:
- dump_wikijs_db.sh
shell invocata da jobs schdulati che genera e ruota i dump di backup del db
- dump_wikijs_YYYYMMDD.sql
I file di dump generati.

In questo modo i dumps generati saranno disponibili sulla macchina host anche se per sbaglio venissero rimossi container e volumi.



### src_postgres / src_docker
**Build_contexts**. Contengono:
- il Dockerfile che elenca le istruzioni per buildare, a partire dall'immagine ufficiale, la nostra app con le personalizzazioni necessarie.
Entrambi i Dockerfile sono adeguatamente commentati.
- i files necessari al processo di build, es. il dump da copiare nel container