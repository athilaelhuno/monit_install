#!/bin/bash


sudo /etc/init.d/asterisk stop

for i in `sudo screen -list | grep .AGI | awk '{print $1}'`; do sudo screen -X -S $i quit;done;
for i in `sudo screen -list | grep .Presence | awk '{print $1}'`; do sudo screen -X -S $i quit;done;
for i in `sudo screen -list | grep .Billing | awk '{print $1}'`; do sudo screen -X -S $i quit;done;