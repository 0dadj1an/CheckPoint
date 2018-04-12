#!/bin/bash -f

#ivosh a laura
#CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh

LOG=/home/admin/scripts/restart_cpservices.log
COUNT=0

cp_restart(){

rm -r $LOG
echo "#################   CPSTOP  ####################" > $LOG 2>&1 && cpstop >> $LOG 2>&1 && echo "##########################################" >> $LOG 2>&1 && echo "####################     CPSTART    ######################" >> $LOG 2>&1  && cpstart >> $LOG 2>&1 && echo "##########################################" >> $LOG 2>&1

}


check_wd(){
    cpwd_admin exist >>$LOG
    a=$?
    if [[ "$a" -eq 255 ]];
      then
        printf "cpwd is not running!!! issue, restarting again...\n" >>$LOG
        cp_restart

      else
        printf "cpwd is running!!!\n" >>$LOG
        printf "cpwd is okay..\n" >>$LOG
        check_cpm
    fi
}

check_cpm(){

    sleep 240
    printf "checking cpm..\n" >>$LOG
    a=$(cpwd_admin getpid -name CPM)

    if [[ "$a" -eq 0 ]];
      then
         cp_restart
      else
          printf "ALL is OKAY\n" >>$LOG
          printf "CPM is okay\n"
          printf "For all details see $LOG"
          exit 0
    fi

}


# main part

main(){

check_wd

}

# call main function
main
