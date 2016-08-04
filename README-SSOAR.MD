# SSOARv5 development guide
## Initial installation
The SSOAR development installation process follows [DSpace 5's installation guide](https://wiki.duraspace.org/display/DSDOC5x/Installing+DSpace) quite closely. This guide assumes you are using Windows 7 64 Bit with Cygwin.

* Install PostgreSQL, Apache Ant, Apache Maven, and Apache Tomcat (`apache-tomcat-8.0.26-windows-x64.zip`), conventionally at `C:\Program Files\apache-${TOOL}-${TOOL_VERSION}\`.


In $HOME/.profile, add the following environment variables (see [Gerrit's `.profile` file](https://git.gesis.org/gerrit.huebbers/dotfiles/blob/master/.profile) for inspiration):
```
export TOMCAT_VERSION=8.0.26
export CATALINA_HOME="/cygdrive/c/Program\ Files/apache-${TOMCAT_VERSION}"
export TOMCAT_SSOAR_INSTANCE_DIR=${HOME}/tomcat-instances/ssoar-$(whoami)/
export SSOAR_SOURCE_DIR=${HOME}/git/ssoar/
export SSOAR_INSTALL_DIR=/cygdrive/c/ssoar/

# add your SSOAR installation's and tools' `bin` directories to your `PATH` environment variable
export PATH=${PATH}:/cygdrive/c/ssoar/bin

# add a general-purpose script directory to your `PATH`. In this directory, place scripts `start-local-ssoar.sh` and `stop-local-ssoar.sh`
export PATH=${PATH}:${HOME}/scripts
```

* Checkout SSOARv5 git project from GESIS' GitLab:
```
git clone git@git.gesis.org:ssoar/ssoar.git
```

* cd into this repository and switch to branch `master`:
```
cd ${SSOAR_SOURCE_DIR} && git checkout master
```

* In this repository's directory, create your own DSpace properties file:
```
cp build.properties $(whoami).properties
```

* Edit file `$(whoami).properties` and change it to accommodate your system. In particular, make sure to give property `dspace.install.dir` a sensible value, e.g. `dspace.install.dir=/ssoar`. For spamming protection, unconfigure `mail.server`, i.e. `mail.server =` (nothing after the equals sign).
* Follow database import steps as outlined in "ssoar-etc/scripts/backup/backup_ssoar.md#Migrating SSOAR 3.x to 5.x".
* Set up a tomcat instance directory, e.g. use Gerrit's setup as a template. Gerrit's setup is located in *this* repository under `ssoar-etc/tomcat-instances/ssoar-huebbegt`.
* Copy command-line start up and shut down scripts into your `$PATH`. These script's are located in *this* repository under `ssoar-etc/scripts/`.
* Stop any possibly running SSOAR instance, then build and install SSOAR, then start this newly-built SSOAR instance:
```
pushd . && cd ${SSOAR_SOURCE_DIR} && stop-local-ssoar.sh && mvn package -Denv=$(whoami) -P \!dspace-jspui,\!dspace-lni,\!dspace-sword,\!dspace-swordv2,\!dspace-rdf && cd dspace/target/ssoar-installer/ && ant update && ant clean_backups && start-local-ssoar.sh && popd
```

* Follow indices refreshment steps as outlined in "ssoar-etc/scripts/backup/backup_ssoar.md#Migrating SSOAR 3.x to 5.x".

## Log files
* Tomcat servlet container log
  * `tail -F ${TOMCAT_SSOAR_INSTANCE_DIR}/logs/catalina.out`
* DSpace logs
  * `tail -F ${SSOAR_INSTALL_DIR}log/dspace.log`
  * `tail -F ${SSOAR_INSTALL_DIR}log/cocoon.log`
  * `tail -F ${SSOAR_INSTALL_DIR}log/checker.log`
  * `tail -F ${SSOAR_INSTALL_DIR}log/frontpage.log`

Also see [Gerrit's tmuxinator configuration files](https://git.gesis.org/gerrit.huebbers/dotfiles/tree/master/.tmuxinator) for nifty log observation setups.

## Deploying to production

    # on a local development computer
    cd ~/git/ssoar
    git pull
    
    # on `master` branch
    # up-to-date "ssoar-prod.properties" file must be located at ~/git/ssoar/ssoar-prod.properties
    # in the SSOAR dev team, currently the convention for keeping the most up-to-date version is on the ssoar.info ssoar.info in /home/ssoar-prod/git/ssoar/ssoar-prod.properties
    
    mvn package -Denv=ssoar-prod -P \!dspace-jspui,\!dspace-lni,\!dspace-rdf
    
    # once maven has finished, copy ssoar-installer to ssoar.info
    scp -r dspace/target/ssoar-installer ssoar.info:/home/$(whoami)/
    
    # now log in to remote ssoar.info machine
    ssh ssoar.info
    
    # move away any old ssoar-installer
    sudo mv /home/ssoar-prod/ssoar-installer /home/ssoar-prod/ssoar-installer.$(TZ=Zulu date +%Y-%m-%dT%H_%M_%S%Z)
    
    # move new ssoar-installer into ssoar-prod's home directory
    sudo mv /home/$(whoami)/ssoar-installer /home/ssoar-prod/
    
    # change ownership of new ssoar-installer to ssoar-prod:ssoar-prod
    sudo chown -R ssoar-prod:ssoar-prod /home/ssoar-prod/ssoar-installer
    
    # shut down ssoar-prod service
    sudo service ssoar-prod stop
    
    # change to user ssoar-prod
    sudo su ssoar-prod
    cd /home/ssoar-prod/ssoar-installer/
    ant update
    
    # exit user ssoar-prod
    exit 
    
    # back to user with sudo rights
    sudo service ssoar-prod start


## Merging upstream DSpace updates into SSOARv5
* First and to be done once, add DSpace's official Github repository ("vanilla DSpace") as a remote repository under the name `upstream`:
```
git remote add upstream https://github.com/DSpace/DSpace.git
```

* Get the latest commits from upstream:
```
git fetch upstream
```

## Git 

* Show which files have been modified (added, removed, etc.) among the upstream DSpace project and the SSOAR v3.5 branch:
```
$ git diff --name-only remotes/upstream/master master
```

* See a file's differences between SSOAR and vanilla DSpace (example shows this for file `dspace/config/xmlui.xconf`, diffing vanilla's master branch and the SSOAR master branch):
```
$ git diff remotes/upstream/master -- dspace/config/xmlui.xconf master -- dspace/config/xmlui.xconf
```

## Software development
### Initial setup
* Clone SSOAR:
```
$ cd ~/git && git clone git@git.gesis.org:ssoar/ssoar.git
```

* Import the SSOAR project into Eclipse IDE for Java EE Developers, Mars release:
In Eclipse, select File -> Import... -> Maven > Existing Maven Projects -> Next -> Browse -> select ~/git/ssoar -> Next
If all went well, your Eclipse workspace should be populated with projects such as "additions", "dspace-parent", "dspace", "dspace-api", etc.

* Create a debug configuration to connect to a running server instance:
In Eclipse, click Run -> Debug Configurations... -> select "Remote Java Application" -> click "New launch configuration" -> a new debug configuration is created.
On the right side, provide a meaningful name, e.g. "Debug Tomcat SSOAR"; make sure that host is "localhost" and port is "8000". Select the source tab ->
click Add... -> File System Directory -> Browse... -> go to "~/git/DSpace" (i.e., the vanilla DSpace directory, which shall be on commit "git checkout -b tags/${DSPACE-VERSION-THAT-THE-SSOAR-PROJECT-IS-USING-AS-MAVEN-DEPENDENCY}") -> OK -> have "search subfolders" selected -> OK.
Back on the source tab -> click Add... -> Java Project -> Select All projects -> OK -> OK.
Make sure that on the "Source Lookup Path", the "Java Projects" come first, then the "DSpace" "File System Directory", then last the "Default" entry. The order is important in order for the connected debugger to choose the correct source files - in case of two identical class names, (e.g. "org.dspace.utils.DSpace" from vanilla DSpace and from SSOAR's Maven overlay customization), the SSOAR customization will be chosen by the debugger to show up on breakpoint triggers.
Click "Apply", to persist these debugger configuration changes. -> Apply -> Close

* Start up SSOAR on a development machine by executing `start-local-ssoar.sh` from the Cygwin command line. `start-local-ssoar.sh` will activate nifty JMX instrumentation, so that e.g. `jvisualvm` can instrument Tomcat and SSOAR. And it activates Tomcat's JPDA capability, which allows above debugger configuration to connect to Tomcat. 

### Certificates
For testing purposes, it's best practice to have a working SSL option for localhost. Tomcat can be set up to provide SSL. Gerrit's configuration files at `ssoar-etc/tomcat-instances/ssoar-huebbegt/` include a keystore and Tomcat configurations with enabled SSL. Either take these files, or set up your own keystore.
To set up your own keystore run the following command:
```
$ keytool -genkey -alias tomcat -keyalg RSA
```
Whenever asked for a password, provide `changeit`.
If asked for "Vor- und Nachname" ("first and last name"), provide `localhost`, as this is the certificate *CN* field.

Once this command has finished, it will have created a file "~/.keystore".

You can then instruct Tomcat to use this keystore by referencing it in `server.xml`:
```
...
<Connector port="8443" protocol="org.apache.coyote.http11.Http11Protocol"
            maxThreads="150" SSLEnabled="true" scheme="https" secure="true"
               clientAuth="false" sslProtocol="TLS" keystoreFile="${user.home}/.keystore" keystorePass="changeit" />
...
```
Later, you can also extract an X.509 certificate from this keystore to file `localhost.cer` by running the following command:
```
keytool -export -keystore .keystore -alias tomcat -file localhost.cer
```

### Development cycle
#### Making DSpace kernel changes
Let's say you want to make modifications or additions to the DSpace kernel. The DSpace kernel is any Java class inside the Maven modules `dspace-api` and `dspace-services`. Changing the source files in these modules likely causes merge conflicts when merging upstream fixes into the SSOAR codebase. To circumvent this problem, the SSOAR git repository leverages DSpace's provided *Maven Overlay* mechanism: Rather than editing the vanilla DSpace kernel source code files directly, add your updated DSpace kernel files to the `${SSOAR_SOURCE_DIR}/dspace/modules/additions/` directory.
For example, let's assume you want to make changes to class `org.dspace.utils.DSpace`:
* Copy file `${VANILLA_DSPACE_SOURCE_DIR}/dspace-services/src/main/java/org/dspace/utils/DSpace.java` to location `${SSOAR_SOURCE_DIR}/dspace/modules/additions/src/main/java/org/dspace/utils/DSpace.java`.
* Make your changes at the file located at `${SSOAR_SOURCE_DIR}/dspace/modules/additions/src/main/java/org/dspace/utils/DSpace.java`.
The DSpace Maven-ant build process will package the changed classes in JAR `additions-....jar` . This JAR is then distributed with all DSpace servlets and within the `${SSOAR_INSTALL_DIR}/lib` directory (latter directory used by the `dspace` command for setting up the classpath).


#### Debugging
Start Tomcat from the command line with `start-local-ssoar.sh`. After server startup has completed, in Eclipse click on the Debug logo caret and select "Debug Tomcat SSOAR". (If there isn't such an entry yet, then do the following: Run -> Debug Configurations... -> select "Debug Tomcat SSOAR" -> click Debug).

Switch to the *Debug* perspective. Set a breakpoint. Interact with DSpace to trigger your breakpoint. In case you get an information "Source not found", make sure that you have added DSpace vanilla source code **and** SSOAR source code as described in the *Initial setup* section above. 

#### Hot deploying changed classes
The aforementioned run and debug configurations allow for instantly redeploying changed source code to Tomcat and the JVM. This is called "hot code deploying" (or "hot code replace" or "hot code swap").
Prerequisites for hot code deploying are:
1. In Eclipse's server configuration view, under "Publishing", have "Automatically publish when resources change" activated
2. Run "Debug Tomcat SSOAR"

Once you changed a Java class and saved it, Eclipse will try to hot-deploy your changes. For many code change scenarios, hot code deploying allows to instantly test out the code changes without going through a rebuild-restart cycle. Some code changes, including adding new methods and new classes, require a rebuild-restart cycle though.

## Building
* To speed up build time, you can exclude specific DSpace servlets that you would not like to build. For instance, if you are currently only editing `dspace-xmlui`, you can tell Maven to exclude all other Servlets from the phase 1 build:
```
$ mvn package -Denv=$(whoami) -P -dspace-jspui,-dspace-lni,-dspace-sword,-dspace-swordv2,-dspace-oai
```

### Architecture

#### xmlui (vanilla plus SSOAR overlay)

##### Initialization

1. web.xml
    1. creates a Spring `DispatcherServlet` with the name `servlet`.
    2. creates several servlet filters
    3. sets the magic `contextConfigLocation` Spring parameter with value `/WEB-INF/spring/*.xml`. This means any beans definition file in that directory will be processed by Spring.
2. [Due to a Spring convention](http://stackoverflow.com/a/3652125/923560), the `servlet` servlet will be configured with the `WEB-INF/spring-servlet.xml` bean configuration. That bean configuration will scan for `@Component`s (including `@Controller`s) in base-package `org.dspace.springmvc`.


### Code snippets
* Find the asset store internal ID for a document handle. This allows to convert a document's URL part (`document/xyz`) to a String (`12345678910111213`). The internal ID defines where an asset store's file is saved in the file system. E.g., a file with internal ID "12345678910111213" is stored as file `[dspace-install]/assetstore/12/34/56/12345678910111213`:

```
select * from bitstream bs where bs.bitstream_id in
  (select bitstream_id from bundle2bitstream b2b where b2b.bundle_id in 
    (select bundle_id from item2bundle i2b where i2b.item_id = 
      (select resource_id from handle where handle = 'document/39972')
    )
  );
```

* Find all metadata from the database associated with a document handle:
```
select * from metadatavalue mdv inner join metadatafieldregistry mdfr on (mdv.metadata_field_id = mdfr.metadata_field_id) where mdv.resource_id = (
select resource_id from handle h where h.handle = 'document/39972') order by mdfr.metadata_schema_id asc, mdfr.element asc, mdfr.qualifier;
```

* Convert between document handle and OAI identifier
```
document/39972
http://ssoar.info/OAIHandler/request?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:gesis.izsoz.de:39972
```

## Instrumentation
If SSOAR is started appropriately, it will allow observation and manipulation of various software components within the JVM and SSOAR itself via JMX and MBeans. Follow Gerrit's `start-local-ssoar.sh`, the `ssoar-prod` SysVinit service script, and Gerrit's `tomcat-instances`.
The JDK is distributed with a JMX client called *Java VisualVM*. VisualVM has to be initially set up to work with MBeans, if not already done so: In the VisualVM window, select *Tools* -> *Plugins*. A new window *Plugins* will open. Select the *Available Plugins* in this window, check the *Install* checkbox for *VisualVM-MBeans* and click *Install*.

Depending on how Tomcat starts up, JVM's JMX capability will be exposed via a dedicated TCP port. In Gerrit's configuration, this is TCP port 9000. To connect VisualVM to this port, create a new connection. In the VisualVM window, select *File* -> *Add JMX connection...*. A new window appears. Here, provide the appropriate configuration, e.g. for *Connection*, provide `localhost:9000`, keep *Use security credentials* unchecked, but check *Do not require SSL connection*. Click OK. The VisualVM window will now include an entry *Local -> localhost:9000*.

When Tomcat starts up, in the Visual VM window double-click the *localhost:9000 (pid someNumber)* entry. After a few seconds, Visual VM will have connected to the JVM and will show different instrumentation views on the right window side.
Select the *MBeans* tab. In its tree list, there is one particular entry called *logging*. It includes several entries, including *config-/OAIHandler* and *config-/ssoar*. Each entry represents an MBean to manipulate SSOAR's *sl4j* loggers during Tomcat's runtime: Sometimes, it is desirable to change logger levels, e.g. to increase the verbosity of some logger(s) to better observe what is going on, or to decrease some logger's verbosity in order to better focus on another logger. These MBeans allow you to do so.
Select one of the entries. To the right side, additional tabs will appear: *Attributes* and *Operations*.

* *Attributes* will show all explicitly configured loggers and their individual logging levels (keep in mind that in log4j, the logging level for a logger, e.g., `org.dspace` will be inherited to nested packages such as `org.dspace.app` - iff `org.dspace.app` has no explicitly configured logging level itself). Double-click on the *Value* entry to see all loggers.
* *Operations* allows to see and manipulate the logging level of an individual logger.
*    To see the individual logging level for a logger, provide that logger's name in the *getLogLevel* row and click the *getLogLevel* button.
*    To change a logger's logging level, provide that logger's name and new log level (`ERROR`, `WARN`, `INFO`, `DEBUG`, or `TRACE`), in that order, on the *setLogLevel* row and click the *setLogLevel* button.

## Connecting remote ssoar.info ports to a local machine
Frequently, work needs to be done on ssoar.info's PostgreSQL database engine, MySQL database engine, or SSOAR itself, be it working with JMS/MBeans or attaching Eclipse's debugger to the live ssoar.info installation.
To do so, you can forward ssoar.info's ports to your local computer. Execute the following command:

    ssh -L 8081:localhost:8080 -L 9000:localhost:9000 -L 8001:localhost:8000 -L 5433:localhost:5432 -L 3307:localhost:3306 ssoar.info

This command will do the following things:
* Provide you with a remote shell on ssoar.info
* Forward some of ssoar.info's ports to your local computer, namely:
*    SSOAR's HTTP port to your local computer's port `8081`. You can now open ssoar.info in your browser by visiting [http://localhost:8081/ssoar](http://localhost:8081/ssoar). This is useful in situations where ssoar.info's reverse proxy (Apache HTTP server) is not running.
*    SSOAR's JMS port to your local computer. Connect to it as if SSOAR was running locally on your computer (`localhost:9000`).
*    SSOAR's Java debug interface (*JPDA*) to your local computer. Connect to it with Eclipse debugger as if SSOAR exposed the debugger port on port 8001 (`localhost:8001`). 
*    SSOAR's PostgreSQL port to your local computer. Connect to it as if PostgreSQL was running locally on your computer on port 5433 (`localhost:5433`). When connecting to it (e.g. with pgAdmin or the `psql` command), don't forget to use ssoar.info PostgreSQL credentials.
*    SSOAR's MySQL port to your local computer. Connect to it as if MySQL was running locally on your computer on port 3307 (`localhost:3307`). When connecting to it (e.g. with HeidiSQL or the `mysql` command), don't forget to use ssoar.info MySQL credentials.

## Troubleshooting
### ssoar.info does not send e-mails
ssoar.info uses `smtp.1und1.de` to send e-mails. That SMTP server uses a self-signed certificate. By default, JavaMail (which is used by DSpace/SSOAR) does not trust self-signed certificates - at least since Java 8. Therefore, add the SMTP server's certificate to Java's *truststore*.

    openssl s_client -connect smtp.1und1.de:465 -showcerts </dev/null 2>/dev/null | openssl x509 -outform der >smtp1und1.der && sudo keytool -importcert -alias smtp1und1 -keystore /etc/ssl/certs/java/cacerts -storepass changeit -file smtp1und1.der

Additionally, make sure that `somebuild.properties` includes the following properties:

    mail.server.port = 587
    mail.extraproperties = mail.transport.protocol=smtp, mail.smtp.socketFactory.fallback=false, mail.smtp.port=587, mail.smtp.auth=true, mail.smtp.starttls.enable=true, mail.smtp.ssl.enable=true, mail.smtp.debug=true, mail.debug.auth=true, mail.debug=true, mail.smtp.ssl.trust=*

Furthermore, iptables should allow `OUPUT` connections on ports 25, 465, and 587.