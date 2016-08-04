#ssoar.info iptables configuration

## iptables snapshot
Generate current iptables configuration snapshot with the following command:

    sudo iptables-save >/tmp/iptables-save.conf

Then copy to git repository:

    cd ~/git/ssoar/ssoar-etc/ssoar.info/configuration/iptables/
    scp ssoar.info:/tmp/iptables-save.conf .

