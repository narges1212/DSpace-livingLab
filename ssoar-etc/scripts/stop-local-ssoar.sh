#!/bin/sh

CATALINA_BASE="${HOME}/tomcat-instances/ssoar-$(whoami)"
export CATALINA_BASE
/bin/sh "${CATALINA_HOME}"/bin/shutdown.sh
