#!/bin/sh
export CATALINA_BASE="/srv/tomcat-instances/ssoar"
/usr/share/tomcat7/bin/shutdown.sh
echo "Tomcat stopped"
