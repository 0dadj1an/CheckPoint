#!/bin/bash -f
#
#==============================================================================
#==============================================================================
# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh

LOG=/var/ivos/secure_xl_check.log

sexure_xl_check(){

    while true;
        sleep 60
        do
            a=$(fwaccel stat | grep "Accelerator Status : " | awk '{print $4}')

            if [[ "$a" == "on" ]];
                then
                     continue
                else
                     date >>$LOG
                     fwaccel on >>$LOG 2>>$LOG
                     printf "################\n" >>$LOG
            fi

        done

}
sexure_xl_check
