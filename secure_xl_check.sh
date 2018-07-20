#!/bin/bash -f
#ivohrbacek@gmail.com
#==============================================================================
#============================================================================
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


################################

#version 2

#!/bin/bash -f
#
#==============================================================================
#==============================================================================
# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh

LOG=/home/hrbacek/scripts/secure_xl_check.log

sexure_xl_check(){

            a=$(fwaccel stat | grep "Accelerator Status : " | awk '{print $4}')

            if [[ "$a" == "on" ]];
                then
                     exit 0
                else
                     date >>$LOG
                     printf "securexl is going to be restarted..current status:\n" >> $LOG
                     fwaccel stat >>$LOG
                     fwaccel on >>$LOG 2>>$LOG
                     printf "################\n" >>$LOG
            fi

}
sexure_xl_check

[Expert@czbr-cp-fw01-e:0]#
