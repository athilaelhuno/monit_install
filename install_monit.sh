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


cd /usr/local/etc/
sudo chmod 777 monitrc

sudo cp monitrc monitrc.ori
sudo sed -e 's/set daemon  60              \# check services at 1-minute intervals/set daemon  10/g' monitrc.ori > monitrc
sudo cp monitrc monitrc.ori
sudo sed -e 's/\# set logfile syslog facility log_daemon/set logfile syslog facility log_daemon/g' monitrc.ori > monitrc
sudo cp monitrc monitrc.ori
sudo sed -e 's/\# set pidfile \/var\/run\/monit.pid/set pidfile \/var\/run\/monit.pid/g' monitrc.ori > monitrc
sudo cp monitrc monitrc.ori
sudo sed -e 's/\# set idfile \/var\/.monit.id/set idfile \/var\/.monit.id/g' monitrc.ori > monitrc
sudo cp monitrc monitrc.ori
sudo sed -e 's/\# set statefile \/var\/.monit.state/set statefile \/var\/.monit.state/g' monitrc.ori > monitrc
sudo cp monitrc monitrc.ori
sudo sed -e 's/\#  include \/etc\/monit.d\/\*/include \/etc\/monit.d\/\*/g' monitrc.ori > monitrc

cd $INSTALL_DIR

sudo cp src/cc_monitor.py /usr/local/bin/
sudo chmod +x /usr/local/bin/cc_monitor.py 
sudo cp src/monit_init  /etc/init.d/monit
sudo chmod +x /etc/init.d/monit
sudo cp src/monit_default /etc/default/monit

sudo mkdir /etc/monit.d/
sudo cp src/mpsanp /etc/monit.d
sudo cp src/screen /etc/monit.d
sudo cp src/startScreen.sh /usr/local/bin/
sudo cp src/stopScreen.sh /usr/local/bin/
sudo cp src/asterisk-down.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/stopScreen.sh
sudo chmod +x /usr/local/bin/startScreen.sh
sudo chmod +x /usr/local/bin/asterisk-down.sh



RUN=1
COUNT=0

while [ $RUN==1 ];do
        interface=`sudo ifconfig eth$COUNT | grep inet\ addr\: | awk '{ print $2 }' | cut -d: -f2`
        if [[ $interface =~ .*161.196..* ]];then
                sudo chmod 777 /etc/monit.d/screen
                cd /etc/monit.d
                sudo cp screen screen.ori
                sudo sed -e 's/  start program = "\/usr\/local\/bin\/cc_monitor.py xxx.xxx.xxx.xxx"/  start program = "\/usr\/local\/bin\/cc_monitor.py '$interface'"/g' screen.ori > screen
                sudo rm -rf screen.ori
                break
        fi
        let COUNT=$COUNT+1
done


sudo /etc/init.d/monit start






