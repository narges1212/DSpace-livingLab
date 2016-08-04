#!/bin/sh
# This script starts up SSOAR within a dedicated Tomcat instance, i.e. it sets and exports the environment variable CATALINA_BASE.
# Further instructions in ssoar-etc/tomcat-instances/README-TOMCAT-INSTANCES.MD

export CATALINA_BASE="${HOME}/tomcat-instances/ssoar-$(whoami)"

export CATALINA_OPTS="-Xmx1024m -Xms1024m -XX:MaxPermSize=512m -Dcom.sun.management.jmxremote 
-Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=9000"

export JAVA_OPTS="-Xmx1024m -Xms1024m -XX:MaxPermSize=512m"

export JPDA_ADDRESS=8000
export JPDA_TRANSPORT=dt_socket

#/bin/sh "${CATALINA_HOME}"/bin/startup.sh
/bin/sh "${CATALINA_HOME}"/bin/catalina.sh jpda start
