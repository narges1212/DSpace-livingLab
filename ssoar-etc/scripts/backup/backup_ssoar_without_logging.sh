#!/bin/sh
set -e

# Under Cygwin, install the following packages: postgresql-client, mysql, expect

# On the server, run "sudo visudo", then add the following line (without the # character)
#Defaults !tty_tickets
# http://unix.stackexchange.com/a/92125/20230

#check if some parent process defined a timestamp (e.g. the logging-enabled wrapper script), and if not, then define it
if [ -z "${WIP_LATEST_SSOAR_BACKUP_TIMESTAMP}" ]; then
    export WIP_LATEST_SSOAR_BACKUP_TIMESTAMP=$(date +"%Y-%m-%dT%H_%M_%SZ")
fi  


printf "SSOAR backup script\n\n"

SSOAR_ADDRESS="ssoar.info"

read -s -p "user SSH%$(whoami) at ${SSOAR_ADDRESS} password: " PASSWORD_SSH_WHOAMI
echo #newline

read -s -p "user Unix-sudo%$(whoami) at ${SSOAR_ADDRESS} password: " PASSWORD_UNIX_WHOAMI
echo #newline

read -s -p "user mysql%root at ${SSOAR_ADDRESS} password: " PASSWORD_MYSQL_ROOT
echo #newline

read -s -p "user SSH%postgres at ${SSOAR_ADDRESS} password: " PASSWORD_SSH_POSTGRES
echo #newline

read -s -p "user postgres%postgres at ${SSOAR_ADDRESS} password: " PASSWORD_POSTGRES_POSTGRES
printf "\n\n" #newline with space

PS3='Where do you want the backup to be created? '
options=("At ~/backups/ssoar/YYYY-MM-DDTHH_MM_SSZ/" "At I:\\SSOAR\\backups\\YYYY-MM-DDTHH_MM_SSZ\\")
select opt in "${options[@]}"
  do
    case $opt in
      "At ~/backups/ssoar/YYYY-MM-DDTHH_MM_SSZ/")
        SSOAR_BACKUPS_ROOT_DIRECTORY="$HOME/backups/ssoar/"
        break
        ;;
      "At I:\\SSOAR\\backups\\YYYY-MM-DDTHH_MM_SSZ\\")
        SSOAR_BACKUPS_ROOT_DIRECTORY="/cygdrive/i/SSOAR/backups/"
        break
        ;;
      *)
        exit 4
        ;;
    esac
  done
  

WIP_SSOAR_BACKUP_DIRECTORY="${SSOAR_BACKUPS_ROOT_DIRECTORY}${WIP_LATEST_SSOAR_BACKUP_TIMESTAMP}/"
echo "Creating new SSOAR backup directory at $WIP_SSOAR_BACKUP_DIRECTORY ..."
# if network drive I:\ makes problems, see https://cygwin.com/ml/cygwin-xfree/2011-08/msg00056.html . For workaround see https://technet.microsoft.com/en-us/library/ee844140(WS.10).aspx . One solution may be to run Cygwin WITHOUT administrator privileges.
mkdir -p $WIP_SSOAR_BACKUP_DIRECTORY

LATEST_SSOAR_BACKUP_DIRECTORY=${SSOAR_BACKUPS_ROOT_DIRECTORY}latest/
echo "If it doesn't exist yet, creating SSOAR latest backup directory ..."
mkdir -p $LATEST_SSOAR_BACKUP_DIRECTORY

PREVIOUSLY_LATEST_TIMESTAMP_FILE="${LATEST_SSOAR_BACKUP_DIRECTORY}latest-timestamp"
if [ ! -f $PREVIOUSLY_LATEST_TIMESTAMP_FILE ]
then
  touch $PREVIOUSLY_LATEST_TIMESTAMP_FILE
  echo "${WIP_LATEST_SSOAR_BACKUP_TIMESTAMP}" >$PREVIOUSLY_LATEST_TIMESTAMP_FILE
fi
PREVIOUSLY_LATEST_TIMESTAMP=$(cat $PREVIOUSLY_LATEST_TIMESTAMP_FILE)
PREVIOUSLY_LATEST_SSOAR_BACKUP_DIRECTORY=${SSOAR_BACKUPS_ROOT_DIRECTORY}${PREVIOUSLY_LATEST_TIMESTAMP}/
  
WIP_DB_DUMPS_DIRECTORY="${WIP_SSOAR_BACKUP_DIRECTORY}db-dumps/"
echo "Creating db-dumps subdirectory at $WIP_DB_DUMPS_DIRECTORY ..."
mkdir -p "$WIP_DB_DUMPS_DIRECTORY"

echo "Setting up MySQL SSH tunnel..."
expect <<- DONE
  spawn ssh -M -S /var/run/ssoar-mysql-socket -fnNT -L 3307:localhost:3306 $(whoami)@${SSOAR_ADDRESS}
  
  set timeout 5
  # see http://stackoverflow.com/a/35801028/923560
  expect {
    # either expect passphrase prompt ...
    "*.ssh/id_rsa':*" {
      # ssh-agent is not running
      log_user 0
      send -- "$PASSWORD_SSH_WHOAMI\r"
      log_user 1
    }
    # ... or wait some time ...
    timeout {
      # ... which allows us to look for the existence of a socket file ...
      if {[file exists /var/run/ssoar-mysql-socket]} {
        # ... whose existence means the SSH port forwarding was established successfully ...
        send_user "mysql socket file exists... continuing\r"
      } else {
        # ... and whose non-existence means the SSh port forwarding failed. Quitting in that case
        send_user "mysql socket file does not exist. This implies SSH port forwarding could not be established. Quitting mysql dump expect script\r"
        exit 2
      }
    }
  }
  set timeout -1
  
  spawn mysqldump --all-databases --user=root --password --protocol=TCP --host=localhost --port=3307 --verbose --result-file=${WIP_DB_DUMPS_DIRECTORY}ssoar_mysql_all_databases_${WIP_LATEST_SSOAR_BACKUP_TIMESTAMP}.sql
  # mysqldump always asks for password
  expect "*?asswor?:*"
  log_user 0
  send -- "$PASSWORD_MYSQL_ROOT\r"
  log_user 1
  expect eof
DONE
echo "Finished mysqldump. Closing socket..."
ssh -S /var/run/ssoar-mysql-socket -O exit $(whoami)@${SSOAR_ADDRESS}


echo "Setting up PostgreSQL tunnel..."

# By default, pg_dumpall prompts for the password repeatedly for each database. To override this default, provide an environment variable PGPASSWORD and start pg_dumpall with the --no-password flag
export PGPASSWORD="$PASSWORD_POSTGRES_POSTGRES"
expect <<- DONE
  spawn ssh -M -S /var/run/ssoar-postgresql-socket -fnNT -L 5433:localhost:5432 postgres@${SSOAR_ADDRESS}
  
  set timeout 5
  # doing expect-ssh-agent magic as commented above in the MySQL dump script
  expect {
    "*.ssh/id_rsa':*" {
      log_user 0
      send -- "$PASSWORD_SSH_POSTGRES\r"
      log_user 1
    }
    timeout {
      if {[file exists /var/run/ssoar-postgresql-socket]} {
        send_user "postgres socket file exists... continuing\r"
      } else {
        send_user "postgres socket file does not exist. This implies SSH port forwarding could not be established. Quitting postgres dump expect script\r"
        exit 2
      }
    }
  }
  set timeout -1
  
  spawn pg_dumpall --verbose --port=5433 --host=localhost --user postgres --no-password --file ${WIP_DB_DUMPS_DIRECTORY}ssoar_postgresql_all_databases_${WIP_LATEST_SSOAR_BACKUP_TIMESTAMP}.backup
  expect eof
DONE
echo "Finished pg_dumpall. Closing socket..."
ssh -S /var/run/ssoar-postgresql-socket -O exit postgres@${SSOAR_ADDRESS}


# FS_DIRECTORY="$SSOAR_BACKUP_DIRECTORY"filesystem/
# echo "Creating filesystem directory at $FS_DIRECTORY ..."
# mkdir -p "$FS_DIRECTORY"

LATEST_FS_DIRECTORY="${LATEST_SSOAR_BACKUP_DIRECTORY}filesystem/"
echo "In case it doesn't exist yet, creating latest filesystem directory at ${LATEST_FS_DIRECTORY} ..."
mkdir -p "${LATEST_FS_DIRECTORY}"

PREVIOUSLY_LATEST_FS_DIRECTORY="${PREVIOUSLY_LATEST_SSOAR_BACKUP_DIRECTORY}filesystem/"
echo "Creating previously-latest filesystem directory at ${PREVIOUSLY_LATEST_FS_DIRECTORY} ..."
mkdir -p "${PREVIOUSLY_LATEST_FS_DIRECTORY}"


LATEST_FS_DSPACE_DIRECTORY="${LATEST_FS_DIRECTORY}dspace/"
echo "In case it doesn't exist yet, creating dspace/ directory at ${LATEST_FS_DSPACE_DIRECTORY} ..."
mkdir -p "${LATEST_FS_DSPACE_DIRECTORY}"

PREVIOUSLY_LATEST_FS_DSPACE_DIRECTORY="${PREVIOUSLY_LATEST_FS_DIRECTORY}dspace/"
echo "Creating dspace/ directory at ${PREVIOUSLY_LATEST_FS_DSPACE_DIRECTORY} ..."
mkdir -p "${PREVIOUSLY_LATEST_FS_DSPACE_DIRECTORY}"

echo "rsyncing /dspace/ directory..."
# see http://serverfault.com/a/98750/127106
RSYNC_SUCCESSFUL=1

set +e
while [[ "${RSYNC_SUCCESSFUL}" -ne 0 ]]
do
  echo "spawning rsync in expect script"
  expect <<- DONE
    set timeout -1
    set remoteRsync "sudo rsync"
    
    send_user "refreshing sudo ticket...\n"
    spawn ssh -t $(whoami)@${SSOAR_ADDRESS} "sudo -v"
    
    expect {
      "*.ssh/id_rsa':*" {
        # if ssh-agent is not active ...
        log_user 0
        send -- "$PASSWORD_SSH_WHOAMI\r"
        log_user 1
        # http://stackoverflow.com/a/1539215/923560
        exp_continue
      }
      "\[sudo\]*" {
        # if ticket is (no longer) fresh
        log_user 0
        send -- "$PASSWORD_UNIX_WHOAMI\r"
        log_user 1
        send_user "Ticket refreshed.\n"
        # http://stackoverflow.com/a/1539215/923560
        exp_continue
      }
      eof {
        send_user "Ticket was still valid. Refreshed.\n"
      }
    }
    
    
    spawn rsync -uav --fuzzy --rsync-path=\$remoteRsync --partial --backup --backup-dir="$PREVIOUSLY_LATEST_FS_DSPACE_DIRECTORY" --delete --stats --exclude=frontpagestore/documents --exclude=exports --exclude=backup $(whoami)@${SSOAR_ADDRESS}:/dspace/ "${LATEST_FS_DSPACE_DIRECTORY}"
    expect {
      "*:*" {
        log_user 0
        send -- "$PASSWORD_SSH_WHOAMI\r"
        log_user 1
        exp_continue
      }
      eof {
        send_user "rsync has exited"
      }
    }
    
    # see http://stackoverflow.com/a/23632210/923560
    puts \$expect_out(buffer)
    lassign [wait] pid spawn_id os_error_flag error_value
    # see http://stackoverflow.com/a/21403432/923560
    if {\$os_error_flag == -1} {
        exit -1
    } elseif {\$error_value != 0} {
        exit \$error_value
    } else {
        exit 0
    }
DONE
  RSYNC_SUCCESSFUL=$?
  echo "RSYNC_SUCCESSFUL? $RSYNC_SUCCESSFUL"
done
set -e


LATEST_FS_VAR_WWW_DIRECTORY="${LATEST_FS_DIRECTORY}var/www/"
echo "In case it doesn't exist yet, creating var/www/ directory at ${LATEST_FS_VAR_WWW_DIRECTORY} ..."
mkdir -p "${LATEST_FS_VAR_WWW_DIRECTORY}"

PREVIOUSLY_LATEST_FS_VAR_WWW_DIRECTORY="${PREVIOUSLY_LATEST_FS_DIRECTORY}var/www/"
echo "Creating var/www/ directory at ${PREVIOUSLY_LATEST_FS_VAR_WWW_DIRECTORY} ..."
mkdir -p "${PREVIOUSLY_LATEST_FS_VAR_WWW_DIRECTORY}"

echo "rsyncing /var/www/ directory..."
# see http://serverfault.com/a/98750/127106
RSYNC_SUCCESSFUL=1

set +e
while [[ "${RSYNC_SUCCESSFUL}" -ne 0 ]]
do
  echo "spawning rsync in expect script"
  expect <<- DONE
    set timeout -1
    set remoteRsync "sudo rsync"
    
    send_user "refreshing sudo ticket...\n"
    spawn ssh -t $(whoami)@${SSOAR_ADDRESS} "sudo -v"
    
    expect {
      "*.ssh/id_rsa':*" {
        # if ssh-agent is not active ...
        log_user 0
        send -- "$PASSWORD_SSH_WHOAMI\r"
        log_user 1
        # http://stackoverflow.com/a/1539215/923560
        exp_continue
      }
      "\[sudo\]*" {
        # if ticket is (no longer) fresh
        log_user 0
        send -- "$PASSWORD_UNIX_WHOAMI\r"
        log_user 1
        send_user "Ticket refreshed.\n"
        # http://stackoverflow.com/a/1539215/923560
        exp_continue
      }
      eof {
        send_user "Ticket was still valid. Refreshed.\n"
      }
    }
    
    
    spawn rsync -uav --fuzzy --rsync-path=\$remoteRsync --partial --backup --backup-dir="$PREVIOUSLY_LATEST_FS_VAR_WWW_DIRECTORY" --delete --stats $(whoami)@${SSOAR_ADDRESS}:/var/www/ "$LATEST_FS_VAR_WWW_DIRECTORY"
    expect {
      "*:*" {
        log_user 0
        send -- "$PASSWORD_SSH_WHOAMI\r"
        log_user 1
        exp_continue
      }
      eof {
        send_user "rsync has exited"
      }
    }
    
    # see http://stackoverflow.com/a/23632210/923560
    puts \$expect_out(buffer)
    lassign [wait] pid spawn_id os_error_flag error_value
    # see http://stackoverflow.com/a/21403432/923560
    if {\$os_error_flag == -1} {
        exit -1
    } elseif {\$error_value != 0} {
        exit \$error_value
    } else {
        exit 0
    }
DONE
  RSYNC_SUCCESSFUL=$?
  echo "RSYNC_SUCCESSFUL? $RSYNC_SUCCESSFUL"
done
set -e

echo "finished SSOAR instance backup script"
