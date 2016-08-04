#!/bin/sh
export CATALINA_BASE="/srv/tomcat-instances/ssoar"
/usr/share/tomcat7/bin/startup.sh
echo "Tomcat started"
