#!/bin/bash -f
#
#==============================================================================
#title      :ntp_updater
#author     :ivo.hrbacek@ixperta.com a laura
#version    :0.0001
# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh

SLEEP=60

while true;
do

/sbin/ntpdate tik.cesnet.cz
a=$?
    if [[ "$a" -eq 1 ]];then
	   /sbin/ntpdate tak.cesnet.cz			             
    fi
    
sleep $SLEEP
done