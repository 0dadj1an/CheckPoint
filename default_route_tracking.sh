#!/bin/bash -f
#==============================================================================
#title      :tracking script
#descrition :scrip trackimg default gw and changing redistribution of static default route to OSPF
#author     :ivo.hrbacek@ixperta.com
#version    :0.1
#usage      :this script is executed via rc.local after reboot

#==============================================================================
source /opt/CPshrd-R80/tmp/.CPprofile.sh

# ARRO ISP1 
# host to modify
HOST=181.30.162.113 

# icmp SLA test count
COUNT=5

#delay time
SLEEP=10 

#log file
LOG=/home/admin/scripts/default_gw_tracking.log

# connection status
STATUS=0


# set route-redistribution to ospf2 from static-route default metric 50 on
while true;
do
        
        PING=$(ping -c $COUNT $HOST | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                if [[ $PING -eq 0 ]]; then
                        sleep $SLEEP
                        PING02=$(ping -c $COUNT $HOST | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                                if [[ $PING02 -eq 0 ]]; then
                                        if [[ $STATUS -eq 0 ]]; then
                                        date >> $LOG
                                        echo "default gw not accessible, canceling redistribution of DGW into OSPF" >> $LOG
                                        clish -c 'lock database override' -s >> $LOG 2>>$LOG
                                        clish -c 'set route-redistribution to ospf2 off' -s >>$LOG 2>>$LOG
                                        a=$?
                                        if [[ "$a" -eq 1 ]];then
                                                echo "configuration error" >> $LOG
                                        else
                                                echo "configuration successfull" >> $LOG
                                        fi
                                        STATUS=1
                                        fi
                                fi
                else
                        PING03=$(ping -c $COUNT $HOST | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
 
                        if [[ $PING03 -gt 0 ]] && [[ $STATUS -eq 1 ]]  ; then
                                date >> $LOG
                                echo "default gw accessible,  installing redistribution of DGW into OSPF" >>$LOG 2>>$LOG
                                clish -c 'lock database override' -s 2>>$LOG
                                clish -c 'set route-redistribution to ospf2 from static-route default metric 50 on' -s >>$LOG 2>>$LOG
                                a=$?
                                if [[ "$a" -eq 1 ]];then
                                        echo "configuration error" >> $LOG
                                else
                                        echo "configuration successfull" >> $LOG
                                fi
                                STATUS=0
                        fi
                fi
sleep $SLEEP
done