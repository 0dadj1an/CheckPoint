#!/bin/bash -f
#
#==============================================================================
#title	    :dbedit lock
#descrition :This script cooperates with auto_install.sh.
#            It is called from auto_install.sh and checking if 
#            database is locked. If yes it prints error message
#            and exiting -> because there is no PID for this script,
#            auto_install can not continue. 
#            If there is no active lock, DB is locked by this script.
#author	    :ivo.hrbacek@avg.com
#version    :0.0001
#usage	    :this script is executed called from auto_install.sh

#==============================================================================

# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R77/tmp/.CPprofile.sh

a=$(exec dbedit -s localhost -globallock 2>&1 &)

   if [[ $a == "Database Already Open" ]];
       then
	 	 	printf "DATABASE is LOCKED, someone is logged into management, no installation will occur...\n"
			printf "log into mgmt and install policy manually by running:\n"
    		printf "/home/admin/git/CheckPoint/auto_install.sh\n"
        exit 1
   
fi
