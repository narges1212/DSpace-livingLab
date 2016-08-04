SSOAR backup script
===================

Creating a backup
-----------------
This script clones all SSOAR-relevant code and data.

In particular, this script:
* asks whether you want to clone ssoar-test or ssoar.info (either named "SSOAR" in the following)
* asks for your ssoar SSH login password, the mysql%root password, and the postgres%postgres password (see Password Safe),
* asks whether the SSOAR_BACKUP_DIRECTORY shall be: 
** on your local machine at ~/backups/ssoar/YYYY-MM-DDT_HH_MM_SSZ/
** or on the *I:\ network drive* at I:\SSOAR\backups\YYYY-MM-DDT_HH_MM_SSZ\
* dumps all content of SSOAR's MySQL instance (most importantly, Typo3 content) and PostgreSQL instance (most importantly, DSpace/SSOAR content) to $SSOAR_BACKUP_DIRECTORY/db-dumps/,
* rsyncs most of SSOAR's /dspace directory to $SSOAR_BACKUP_DIRECTORY (most importantly, Tomcat configuration, the ${SSOAR_INSTALL_DIR} including DSpace and SSOAR configurations, modifications, binaries, Solr data, and the assetstore with PDFs). It does not rsync most of the /dspace/frontpagestore/ directory, as that data is a cache, is redundant, and will be recalculated lazily.

NOTICE: If you want to backup to GESIS' *I:\ network drive* and you are using Cygwin, then you will need to run Cygwin WITHOUT administrator rights. Only then will Cygwin be able to access data from /cygdrive/i/**

The ssoar-test backup at 2015-11-13T15_15_55Z had a size of 43 GiByte.
The ssoar.info backup at 2015-12-15T17_49_58Z had a size of 112 GiByte.

This script requires a Unix user account with sudo root privileges.
Also this script requires to access the SSOAR server as Unix users `postgres`. Therefore, append your `rsa_id.pub` content to `/var/lib/postgres/.ssh/authorized_keys`. Assuming your SSOAR Unix user already has a `~/.ssh/authorized_keys` with your `rsa_id.pub` content, then run the following command as your Unix user:
```
sudo cat ~/.ssh/authorized keys >>/var/lib/postgres/.ssh/authorized_keys
```

To run the backup script, execute `backup_ssoar.sh`.

Restore and run a backup on your local machine
----------------------------------------------
NOTICE: To run a backup that has been stored on GESIS' I:\ network drive, first copy that backup to your local machine. In case copying some files does not work, make sure the network drive files have permissions that allow you to copy files. This scenario may happen if a user other than you has initially created the backup.

Note that the restore process will overwrite any SSOAR/DSpace data you currently have at the "default SSOAR database locations". These locations are
* for PostgreSQL: the *postgres*, *dspace*, *dspace5*, and *ssoar* databases.
* for MySQL: the *typo3database*

```
cd $SSOAR_BACKUP_DIRECTORY/YYYY-MM-DDT_HH_MM_SSZ/db-dumps

```
Extract the individual databases "dspace" and "ssoar" from the backup, then import these invidiual databases (extraction script `pgx_extract_db.sh available` from *this* repository):
```
pgx_extract_db.sh ssoar-test_postgresql_all_databases_YYYY-MM-DDT_HH_MM_SSZ.backup ssoar > ssoar-database.backup
pgx_extract_db.sh ssoar-test_postgresql_all_databases_YYYY-MM-DDT_HH_MM_SSZ.backup dspace > dspace-database.backup
dropdb --host=localhost --username=ssoar ssoar
createdb --host=localhost --encoding=Unicode --username=ssoar ssoar
psql --host=localhost --username=ssoar --dbname=ssoar < ssoar-database.backup
dropdb --host=localhost --username=dspace dspace
createdb --host=localhost --encoding=Unicode --username=dspace dspace
psql --host=localhost --username=dspace --dbname=dspace < dspace-database.backup
```

Import MySQL tables:
```
mysql --user=root --password --host=localhost --port=3306 --protocol=TCP --verbose < ssoar-test_mysql_all_databases_YYYY-MM-DDT_HH_MM_SSZ.sql
```

Create a symlink pointing /dspace to ~/backups/dspace/YYYY-MM-DDT_HH_MM_SSZ/ :
```
ln -s ~/backups/dspace/YYYY-MM-DDT_HH_MM_SSZ/ /dspace
```

On Windows systems, open `/dspace/tomcat7/conf/server.xml` and fix all contexts' `baseUrl`. That is:
* Replace all occurences of `/dspace/webapps/` with `c:/Users/$(whoami)/backups/dspace/YYYY-MM-DDT_HH_MM_SSZ/webapps/`
* Also, replace all occurences of "/dspace/dspace5/webapps/` with `c:/Users/$(whoami)/backups/dspace/YYYY-MM-DDT_HH_MM_SSZ/dspace5/webapps/
* Also, comment out the XML element `<Connector port="8443" ... />`
* Also, remove Contexts `intern` and `pdf`.


On Windows systems, open `/dspace/config/dspace.cfg`:
* Replace all occurences of ` /dspace` (notice leading space) with ` c:/Users/$(whoami)/backups/dspace/YYYY-MM-DDT_HH_MM_SSZ` (notice leading space).
* Replace:
** `mail.server.username = `
** `mail.server.password = `
** `ssoar.frontpage.metadataURLPrefix = http://localhost:8080/ssoar/metadata/handle`
** `dspace.hostname = localhost:8080`


In the `/dspace/webapps/` directory, go into the `sword`, `ssoar`, and `oai` directories. In each of those directories, edit `WEB-INF/web.xml`:
* Change `<param-value>/dspace/config/dspace.cfg</param-value>` to `<param-value>c:/Users/$(whoami)/backups/dspace/YYYY-MM-DDT_HH_MM_SSZ/config/dspace.cfg</param-value>`
* Change `<param-value>/dspace</param-value>` to `<param-value>c:/Users/$(whoami)/backups/dspace/YYYY-MM-DDT_HH_MM_SSZ</param-value>`


In `/dspace/webapps/solr/WEB-INF/web.xml`:
* Change `/dspace/solr` to `c:/Users/huebbegt/backups/dspace/YYYY-MM-DDT_HH_MM_SSZ/solr`

Start up SSOAR:
```
unset CATALINA_HOME && unset CATALINA_BASE && /dspace/tomcat7/bin/startup.sh
```

Troubleshooting
===============
It's good practice to rebuild any kind of search index in SSOAR. This may even be a requirement in case [http://localhost:8080/solr](http://localhost:8080/solr) reports an 500 Server error (`FileNotFoundException: "segment not found"` etc.).

To rebuild DSpace-3-based SSOAR indices, first shut down SSOAR:
```
/dspace/tomcat7/bin/shutdown.sh
```
and make sure no DSpace-related java process is still running.
Then run the following commands:
```
rm -rf /dspace/solr/oai/data
rm -rf /dspace/solr/search/data
rm -rf /dspace/solr/statistics/data
```

Start up SOAR:
```
/dspace/tomcat7/bin/startup.sh
```

Run the following DSpace commands:
```
/dspace/bin/dspace.bat update-discovery-index -b
/dspace/bin/dspace.bat index-init -rebuild -full
/dspace/bin/dspace.bat oai import -cov
```

Manual backup validation steps
==============================
Check `backup.log` for any errors, e.g. search for `Permission denied` entries.

* Visit [http://localhost:8080/ssoar/discover](http://localhost:8080/ssoar/discover). Make sure that there is no redirect to *ssoar.info* and that the page renders properly.

* Visit [http://localhost:8080/ssoar/handle/community/10100/discover](http://localhost:8080/ssoar/handle/community/10100/discover). Make sure that there is no redirect to *ssoar.info* and that the page renders properly.

* Visit [http://localhost:8080/ssoar/handle/document/41988](http://localhost:8080/ssoar/handle/document/41988). Make sure that there is no redirect to ssoar.info and that the page renders properly.

* Visit [http://localhost:8080/ssoar/bitstream/handle/document/41988/ssoar-rcr-2015-1-sherry-The_Complexity_Paradigm_for_Studying.pdf?sequence=1](http://localhost:8080/ssoar/bitstream/handle/document/41988/ssoar-rcr-2015-1-sherry-The_Complexity_Paradigm_for_Studying.pdf?sequence=1). Make sure that there is no redirect to ssoar.info. Make sure that a PDF opens up and that this PDF has an SSOAR frontpage.


To shut down SSOAR:
$ unset CATALINA_HOME && unset CATALINA_BASE && /dspace/tomcat7/bin/shutdown.sh


Migrating SSOAR 3.x to 5.x
==========================
Stop any running SSOAR 3.x service:
```
sudo service ssoar stop
```

create a Postgres user named ssoar (if it does not exist yet):
```
createuser --host=localhost --username=postgres --no-superuser --pwprompt ssoar
```

copy dspace/assetstore.

extract PostgreSQL databases "dspace" and "ssoar" from full database dump, then import them:
```
pgx_extract_db.sh ssoar-test_postgresql_all_databases_YYYY-MM-DDT_HH_MM_SSZ.backup ssoar > ssoar-database.backup
pgx_extract_db.sh ssoar-test_postgresql_all_databases_YYYY-MM-DDT_HH_MM_SSZ.backup dspace > dspace-database.backup
dropdb --host=localhost --username=ssoar ssoar
createdb --host=localhost --encoding=Unicode --username=ssoar ssoar
psql --host=localhost --username=ssoar --dbname=ssoar <ssoar-database.backup
dropdb --host=localhost --username=dspace dspace
createdb --host=localhost --encoding=Unicode --username=dspace dspace
psql --host=localhost --username=dspace --dbname=dspace <dspace-database.backup
```

See current database format:
```
cd /srv/ssoar/bin && sudo ./dspace database info
```

Open a second shell and follow migration log:
```
tail -F /srv/ssoar/log/dspace.log.$(date "+%Y-%m-%d")
```

Run database migration:
```
sudo ./dspace database migrate
```

The migration may take a few seconds. A last line should read something similar to:
`2016-01-07 14:06:09,252 INFO  org.flywaydb.core.internal.command.DbMigrate @ Successfully applied 5 migrations to schema "public" (execution time 16:38.044s).`
Observation on Windows 7: The command might not exit despite the migration having successfully run. Cancel the running process by sending a `SIGINT` (Ctrl+C).

The database migration can be considered successful when seeing confirming migration messages in the log and by seeing confirming output from `sudo ./dspace database info`; output should read state `Success` for all versions beginning from 3.0 and newer.

Have logs open:
```
tail -F /srv/ssoar/log/dspace.log.$(date "+%Y-%m-%d") 
tail -F /srv/tomcat-instances/ssoar/logs/catalina.out
```

Start up SSOAR:
```
sudo service ssoar start
```

At the moment you visit the XMLUI page, SSOAR will re-index all documents for the *Discovery* index concurrently to the running service. There will be output similar to 
```
org.dspace.storage.rdbms.DatabaseUtils @ Post database migration, reindexing all content in Discovery search and browse engine"
org.dspace.discovery.SolrServiceImpl @ Wrote Item: document/24213 to Index" in the dspace.log file.
```
This automatic indexing shall have identical results as if the following command was run: `sudo ./dspace index-discovery -b`. Creating the Discovery index may take 10 minutes and more.

Once the Discovery indexing has finished, you can continue with the next step. It's best practice not to run several indexing processes concurrently, as this may result in a crashing DSpace due to *OutOfMemoryException*.

While SSOAR is running or not running, update the *advanced-search* Lucene indices:
```
sudo ./dspace index-lucene-update
```
This command may take 8 minutes and longer. You can see processing in dspace.log. When this command has finished, you shall see results when using *advanced-search*.

While SSOAR is running or not running, refresh the OAI Solr indices:
```
sudo ./dspace oai import
```
This command may take 5 minutes and longer. You can see processing on stdout. When this command has finished and you visit [http://ssoar-address/oai/request?verb=ListIdentifiers&metadataPrefix=oai_dc](http://ssoar-address/oai/request?verb=ListIdentifiers&metadataPrefix=oai_dc) you shall see records (and not `Error - No matches for the query`).