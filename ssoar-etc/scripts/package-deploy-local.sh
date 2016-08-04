#!/bin/bash
set -e

SSOAR_ETC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SSOAR_ETC_DIR}"
source helpers.sh
cd ..
SSOAR_SOURCE_DIR="$(pwd)"
SSOAR_WIN_INSTALL_DIR=$(get_property "$(whoami)".properties dspace.install.dir)

mvn package -Denv="$(whoami)" && cd dspace/target/ssoar-installer/ && ant update

#assuming this script runs in a Cygwin environment
SSOAR_INSTALL_DIR=$(convert_win_path_to_cygwin_path "${SSOAR_WIN_INSTALL_DIR}")
cp -a "${SSOAR_ETC_DIR}"/"$(whoami)"/tomcat/ "${SSOAR_INSTALL_DIR}"/tomcat/
cd "${SSOAR_INSTALL_DIR}"/tomcat/bin/
