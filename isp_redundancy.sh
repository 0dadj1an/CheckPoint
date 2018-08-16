
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
HOST_PRIMARY=XXX
HOST_SECONDARY=YYY

# icmp SLA test count
COUNT=5

#delay time
SLEEP=5
# ------------------------------------------------------------


#log file
mkdir /home/admin/scripts/
echo "" > /home/admin/scripts/default_gw_tracking.log
LOG=/home/admin/scripts/default_gw_tracking.log

# connection status
STATUS=0


date >> $LOG
echo "Default_gw_tracking.sh started" >> $LOG
echo "Starting SLA loop with following parameters:" >> $LOG
echo " SLA count value= $COUNT" >> $LOG
echo " SLA sleep value= $SLEEP" >> $LOG


while true;
do
    CLUSTER_STATE=$(cphaprob state | grep "(local)" | awk '{print $5}') >>$LOG 2>>$LOG
    echo $CLUSTER_STATE >>$LOG 2>>$LOG

    if [[ "$CLUSTER_STATE" == "Active" ]];
   
        then
        
        echo "I am ACTIVE, checking default route.." >>$LOG 2>>$LOG

        PING01=$(ping -c $COUNT $HOST_PRIMARY | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
        if [[ $PING01 -eq 0 ]]; then
            sleep $SLEEP
            PING02=$(ping -c $COUNT $HOST_PRIMARY | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                if [[ $PING02 -eq 0 ]]; then
                    if [[ $STATUS -eq 0 ]]; then
                        date >> $LOG
                        echo "Default GW not accessible, changing static route to $HOST_SECONDARY" >> $LOG
                        clish -c "lock database override" -s >> $LOG 2>>$LOG
                        clish -c "set static-route default nexthop gateway address $HOST_SECONDARY on" -s >>$LOG 2>>$LOG
                        clish -c "set static-route default nexthop gateway address $HOST_PRIMARY off" -s >>$LOG 2>>$LOG
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
            PING03=$(ping -c $COUNT $HOST_PRIMARY | grep received | cut -d ',' -f2 | cut -d ' ' -f2)

            if [[ $PING03 -gt 0 ]] && [[ $STATUS -eq 1 ]]  ; then
                date >> $LOG
                echo "Default GW accessible, changing static route to $HOST_PRIMARY " >>$LOG 2>>$LOG
                clish -c "lock database override" -s 2>>$LOG
                clish -c "set static-route default nexthop gateway address $HOST_PRIMARY on" -s >>$LOG 2>>$LOG
                clish -c "set static-route default nexthop gateway address $HOST_SECONDARY off" -s >>$LOG 2>>$LOG
                a=$?
                if [[ "$a" -eq 1 ]];then
                    echo "Configuration error" >> $LOG
                else
                    echo "Configuration successfull" >> $LOG
                fi
                STATUS=0
            fi
        fi

    else
        echo "I am STANDBY, checking if I was active and if I changed default route.." >>$LOG 2>>$LOG
        PING04=$(ping -c $COUNT $HOST_PRIMARY | grep received | cut -d ',' -f2 | cut -d ' ' -f2)

            if [[ $PING04 -gt 0 ]] && [[ $STATUS -eq 1 ]]  ; then
                date >> $LOG
                echo "I am STANDBY or DOWN in state, but default GW is accessible and route was changed, changing static route back to $HOST_PRIMARY " >>$LOG 2>>$LOG
                clish -c 'lock database override' -s 2>>$LOG
                clish -c 'set static-route default nexthop gateway address $HOST_PRIMARY on' -s >>$LOG 2>>$LOG
                clish -c 'set static-route default nexthop gateway address $HOST_SECONDARY off' -s >>$LOG 2>>$LOG
                a=$?
                if [[ "$a" -eq 1 ]];then
                    echo "Configuration error" >> $LOG
                else
                    echo "Configuration successfull" >> $LOG
                fi
                STATUS=0
            fi
        echo "No change..." >>$LOG 2>>$LOG                
	fi
   
sleep $SLEEP
done