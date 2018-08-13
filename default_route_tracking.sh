#!/bin/bash -f
#==============================================================================
#title      :tracking script; author: Ivo Hrbacek
#descrition :scrip trackimg default gw and changing redistribution of static default route to OSPF
#author     :ivo.hrbacek@ixperta.com
#usage      :this script is executed via rc.local after reboot
#version    :1.0
#==============================================================================
source /opt/CPshrd-R80/tmp/.CPprofile.sh

# -----------------------------------------------------------
# ISP
# host to modify
HOST=XXX

# icmp SLA test count
COUNT=5

#delay time
SLEEP=10
# ------------------------------------------------------------


#log file
LOG=/home/admin/scripts/default_gw_tracking.log

# connection status
STATUS=0


date >> $LOG
echo "Default_gw_tracking.sh started" >> $LOG
echo "Starting SLA loop with following parameters:" >> $LOG
echo " SLA count value= $COUNT" >> $LOG
echo " SLA sleep value= $SLEEP" >> $LOG


# set route-redistribution to ospf2 from static-route default metric 50 on
while true;
do

    PING01=$(ping -c $COUNT $HOST | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
        if [[ $PING01 -eq 0 ]]; then
            sleep $SLEEP
            PING02=$(ping -c $COUNT $HOST | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                if [[ $PING02 -eq 0 ]]; then
                    if [[ $STATUS -eq 0 ]]; then
                        date >> $LOG
                        echo "Default GW not accessible, canceling redistribution of DGW into OSPF" >> $LOG
                        clish -c 'lock database override' -s >> $LOG 2>>$LOG
                        clish -c 'set route-redistribution to ospf2 off' -s >>$LOG 2>>$LOG
                        a=$?
                        if [[ "$a" -eq 1 ]];then
                            echo "Configuration error" >> $LOG
                        else
                            echo "Configuration successfull" >> $LOG
                        fi
                    STATUS=1
                    fi
                fi
        else
            PING03=$(ping -c $COUNT $HOST | grep received | cut -d ',' -f2 | cut -d ' ' -f2)

            if [[ $PING03 -gt 0 ]] && [[ $STATUS -eq 1 ]]  ; then
                date >> $LOG
                echo "Default GW accessible, installing redistribution of DGW into OSPF" >>$LOG 2>>$LOG
                clish -c 'lock database override' -s 2>>$LOG
                clish -c 'set route-redistribution to ospf2 from static-route default metric 50 on' -s >>$LOG 2>>$LOG
                a=$?
                if [[ "$a" -eq 1 ]];then
                    echo "Configuration error" >> $LOG
                else
                    echo "Configuration successfull" >> $LOG
                fi
                STATUS=0
            fi
        fi
sleep $SLEEP
done
