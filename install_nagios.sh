#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
apt-get update
apt-get install -y wget build-essential php5-gd wget libgd2-xpm libgd2-xpm-dev libapache2-mod-php5 apache2-utils daemon
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.2.tar.gz
wget https://www.nagios-plugins.org/download/nagios-plugins-1.5.tar.gz
tar -xzf nagios-4.0.2.tar.gz
tar -xzf nagios-plugins-1.5.tar.gz
cd nagios-4.0.2/
./configure --with-nagios-group=nagios --with-command-group=nagcmd --with-mail=/usr/bin/sendmail
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
cd ../nagios-plugins-1.5
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install
mkdir /usr/local/nagios/var/rw
chmod 777 /usr/local/nagios/var/rw/ -R
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
cd /etc/init.d/
rm nagios
wget https://raw.github.com/curvedental/ubuntu_nagios4_init/master/nagios
chmod 755 nagios
/etc/init.d/apache2 restart
/etc/init.d/nagios restart
