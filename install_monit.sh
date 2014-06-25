#!/bin/bash
INSTALL_DIR=`pwd`

sudo tar xzf monit-5.8.1.tar.gz
sudo mv monit-5.8.1 /usr/src/
cd /usr/src/monit-5.8.1

sudo aptitude install libpam-dev

sudo ./configure
sudo make && sudo make install
sudo cp /usr/src/monit-5.8.1/monitrc /usr/local/etc/monitrc
sudo chmod 700 /usr/local/etc/monitrc

##Configurar sed para monitrc

sudo cp /usr/local/etc/monitrc /usr/local/etc/monitrc.ori
cd /usr/local/etc/
sudo chmod 777 monitrc


sudo sed -e 's/set daemon  60              # check services at 1-minute intervals/set daemon  10/' monitrc.ori > monitrc
sudo sed -e 's/# set logfile syslog facility log_daemon/set logfile syslog facility log_daemon/' monitrc.ori > monitrc
sudo sed -e 's/# set pidfile /var/run/monit.pid/set pidfile /var/run/monit.pid/' monitrc.ori > monitrc
sudo sed -e 's/# set idfile /var/.monit.id/set idfile /var/.monit.id/' monitrc.ori > monitrc
sudo sed -e 's/# set statefile /var/.monit.state/set statefile /var/.monit.state/' monitrc.ori > monitrc
sudo sed -e 's/#  include /etc/monit.d/*/include /etc/monit.d/*/' monitrc.ori > monitrc

cd $INSTALL_DIR

sudo cp src/cc_monitor.py /usr/local/bin/
sudo chmod +x /usr/local/bin/cc_monitor.py 
sudo cp src/monit_init  /etc/init.d/monit
sudo chmod +x /etc/init.d/monit
sudo cp src/monit_default /etc/default/monit

sudo mkdir /etc/monit.d
sudo cp src/mpsanp /etc/monit.d
sudo cp src/stopScreen.sh /usr/local/bin/


sudo /etc/init.d/monit start






