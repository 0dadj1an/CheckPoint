#!/bin/bash -f
#
#==============================================================================


# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh

#This script will change all open sessions which don't have any changes and locks to status-"DISCARDED"

#CHECKANSWER=""
#    while ! [[ "$CHECKANSWER" =~ [yYnN] ]]
#    do
#        echo -n "Runing this script will discard all OPEN Web_API sessions with no locks or changes. Are you sure you want to continue? (Y/N) "
#        read CHECKANSWER
#    done

#    if [[ "$CHECKANSWER" =~ [nN] ]]
#    then
#        echo "Won't run this script . Exiting..."
#       exit 1
#    fi

psql_client cpm postgres< discard_open_sessions.sql >delete.log 2>delete.log

exit 0



