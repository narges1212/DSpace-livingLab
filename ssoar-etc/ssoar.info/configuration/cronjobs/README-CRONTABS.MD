#cronjobs for ssoar.info

##crontab installation instructions
Given file crontab-$(whoami), switch to user $(whoami), then run the following command:

    $ crontab crontab-$(whoami)
e.g.,

    $ sudo chown ssoar:ssoar crontab-ssoar && sudo cp crontab-ssoar /home/ssoar/ && sudo -u ssoar -s /bin/bash -c 'crontab /home/ssoar/crontab-$(whoami)'

##crontab backup instructions
    $ sudo su $SOME_USER
    $ crontab -l >/tmp/crontab-$(whoami)

Then, to copy this crontab dump:

    # on local machine
    cd ~/git/ssoar/ssoar-etc/ssoar.info/configuration/cronjobs/
    scp ssoar.info:/tmp/crontab-ssoar-prod .
