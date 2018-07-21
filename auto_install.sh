#!/bin/bash -f
#
#==============================================================================
#title	    :Policy installation script
#descrition :This script reads policy targets for
#            policy installation via git and load policy into them. 
#            Script can also read targets from arguments passed to script for 
#            manual installation (./auto_install cz-bo-fw-b00), this
#            requires manual DB lock via GUI
#author	    :ivo.hrbacek@avg.com
#version    :0.0002, for R77.30 platform
#usage	    :this script is executed on daily basis via cron
#            can be executed also manually together with arguments

#==============================================================================

# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R77/tmp/.CPprofile.sh


#variables and input files
INSTALLFILE=/PATH TO GIT FOLDER/TO_INSTALL # file where tagrets for installation are define
MULTIPLE=/PATH TO GIT FOLDER/MULTIPLE   # file where are defined firewalls with same policy
DBEDIT=/PATH TO FILE/dbedit.txt  # help file
LOG=/PATH TO FILE/install_issues.txt  # log file
OLDINSTALLFILE=/PATH TO FILE/TO_INSTALL_OLD # backup for TO_INSTALL
LOCKSCRIPT=/PATH TO FILE/dbedit.sh  # db lock script for locking database
PID=''




#######################################
# policy finder
# Globals:
#   DBEDIT, LOG
# Arguments:
#   one argument, policy target or magic keyword from input file
# Returns:
#   NO, calling install_policy: function when fwm load compiling and loading
#   code to fw
#
#######################################
find_policy() {

  while true;
  do
     # magic keywords ALLow to instALL policy package on project firewalls (shared policy)

     if [[ "$1" == "MULTIPLE" ]]; 
        then 
            printf "########################\n"
            printf "install objects: $1\n"   
            install_policy $1 
            break 
     fi

     

#help file DBEDIT.txt finds to identify policy package from CP db 
#if found it is formated and sent to function for instalation 
#if file exists put magic command for finding to file, else create the file and then put the command

      if [[ -f "$DBEDIT" ]];
	 then       
		echo "print install_state_details $1" >$DBEDIT  
         else 
		echo "" >$DBEDIT 
		echo "print install_state_details $1" >$DBEDIT
      fi
            
      printf "########################\n"
     printf "install object: $1\n"

# run DBEDIT to find policy for target
      b=$(dbedit -local -f $DBEDIT | grep policy_name | sort -u | awk -F':' '{ gsub(" ", "", $0 ); print $2 }' 2>>$LOG) 

# if there is not name for non existing target, LOG it and continue

      if [[ -z "$b" ]]; 
         then 
             echo "###############################################" >>$LOG
             echo   "firewall name $1 not found" >>$LOG
	     echo "###############################################" >>$LOG
	     break
         else
             printf "policy package: $b\n"
    	     install_policy $1 $b 
	     break
       fi
  done
} 


#######################################
# policy installer
# Globals:
#   MULTIPLE, LOG
# Arguments:
#   one argument in case of there is shared policy for targets
#   two arguments for target defined via input file (targate name + policy package)
# Returns:
#   NO
#  run fwm load command, compile and install policy to targets,
#  when finished returns back to autoinstall method
#######################################
install_policy(){


 if [[ "$1" == "MULTIPLE" ]];
    then
        echo "START" >>$LOG
	echo "policy installation starting: $1" >>$LOG 
        fwm load -c $MULTIPLE "\$FWDIR"/conf/policy_MULTIPLE.W >>$LOG 2>>$LOG # policy name depends on your env
        a=$?
	  if [[ "$a" -eq 1 ]];
         then
	         printf "installation failed for $1\n"
	     else
        	 printf "installation success for $1\n"
	      
         fi

        echo "policy installation end: $1" >>$LOG
	echo "STOP" >>$LOG 
        return
 fi

 
###non magic installation
  echo "START" >>$LOG
  echo "policy installation starting: $1" >>$LOG 
  fwm load "\$FWDIR"/conf/$2".W" $1 >>$LOG 2>>$LOG
 a=$?
	if [[ "$a" -eq 1 ]];
           then
	     printf "installation failed for $1\n"
	    
           else
        	printf "installation success for $1\n"
	      
    fi
  echo "policy installation end: $1" >>$LOG
  echo "STOP" >>$LOG
 return

}


#######################################
# output formating
# Globals:
#   LOG
# Arguments:
#   no
# Returns:
#   printing the output
#######################################
output(){
             printf "\n"
             printf "####VERIFICATION ISSUES####\n"
                     echo | awk '/START/{flag=1;next}/END/{flag=0}flag' $LOG | grep -B 1 -A 1 "Verification Errors/Warnings"
             printf "\n"
             printf "####TIMEOUT ISSUES####\n"
                     echo | awk '/START/{flag=1;next}/END/{flag=0}flag' $LOG | grep -B 1 -A 1 "Operation incomplete due to timeout."
             printf "\n"
             printf "####SIC ISSUES####\n"
                     echo | awk '/START/{flag=1;next}/END/{flag=0}flag' $LOG | grep -B 1 -A 1 "Reason: SIC General Failure"
             printf "\n"
             printf "####UNKNOWN FIREWALLS####\n"
                     echo | awk '/firewall name/' $LOG
             printf "\n"
             
             printf "COMPLETE INSTALATION LOG ON FWM IN:\n"
             printf  "/home/admin/scripts/install_policy/install_issues.txt\n"
             printf "\n"
}


#######################################
# update from git server
# Globals:
#   LOG, GIT
# Arguments:
#   no
# Returns:
#   exit when there is error with git
#   else return with 0 (OK)
#   when finished returns back to MAIN part and
#   autoinstall method continue
#######################################
git_pull() {
git pull >>$LOG 2>>$LOG 
a=$?
	if [[ "$a" -eq 1 ]];
 then
	printf "ISSUE WITH GIT PULL, NO DEFINITIONS DOWNLOADED...\n"
	exit 1
 else
	printf "GIT PULL OK\n"
	printf "\n"
	printf "TARGETS FOR INSTALLATION\n"
	cat $INSTALLFILE
	printf "\n"
	return
 fi
}


#######################################
# update to git server
# Globals:
#   INSTALLFILE, LOG, GIT
# Arguments:
#   no
# Returns:
#   Exit when there is error with git.
#   Removing policy definitions from TO_INSTALL and pushes 
#   default TO_INSTALL to git server
#   else return with 0 (OK).
#   When finished returns back to MAIN part
#   it is executed before script finnish.
####################################### 
git_push() {
cat $INSTALLFILE > $OLDINSTALLFILE
echo "DELETE ME AND START" > $INSTALLFILE & # delete targets locALLy
sleep 1
git commit -a -m "AUTOINSTALLATION COMPLETE, UPLOADING DEFAULT TO_INSTALL" >>$LOG 2>>$LOG
a=$?
	if [[ "$a" -eq 1 ]];
 then
	printf "ISSUE WITH GIT COMMIT, CAN NOT COMMIT CREATION OF DEFAUL FILE TO_INSTALL ...\n"
	exit 1
	
 else
	printf "GIT COMMIT OK\n"
 fi
sleep 1
git push >>$LOG 2>>$LOG  # push to central git
b=$?
	if [[ "$b" -eq 1 ]];
 then
	printf "ISSUE WITH GIT PUSH TO GIT SERVER...\n"
	
 else
	printf "GIT PUSH OK\n"
 fi
}


#######################################
# CP DB lock
# Globals:
#   PID
# Arguments:
#   no
# Returns:
#   Exit when there is error database lock.
#   Cooperation with dbedit.sh script,
#   which locking the database.
#   When there is no lock done by this
#   script auto_install finishes with exit. 
#   
####################################### 
db_lock(){
PID=$(ps -e | grep 'dbedit.sh' | head -n 1 | awk '{print $1}')
if [[ -z "$PID" ]];
 then
	 printf "DATABASE LOCK ISSUE\n"
 exit 1	
fi
return
}


#######################################
# CP DB lock release
# Globals:
#   PID
# Arguments:
#   no
# Returns:
#   Killing dbedit.sh script for DB lock.
#   When script was already finnished,
#   for example some admin had to do
#   some emergency action on FWM,
#   notify message is written
#   
####################################### 
kill_dblock(){
kill -9 $PID >>$LOG 2>>$LOG
 a=$?
	if [[ "$a" -eq 1 ]];
            then
	         printf "EMERGENCY ACTION OCCURRED!!!\n"
                printf "somebody released DB lock during policy installations ...\n"
                printf "Please avoid these cases and check if changes on FWM did not affect installation set!\n"
            else
	        return
        fi
}


#######################################
# autoinstall method checking 
# Globals:
#   INSTALLFILE
# Arguments:
#   None
# Returns:
#   None, reading file with targets,
#   just non-empty lines are relevant,
#   checking if there is not default TO_INSTALL 
#   definition, if yes, returning 1 to MAIN CODE part
#   autoinstall than exit from code 
#   calling find_policy method
#######################################
auto_install () {      
if [[ -f "$INSTALLFILE" ]];
       then
            cat $INSTALLFILE | while IFS=: read line 
                   do     #do just for non-empty lines 
				    [ -z "$line" ] && continue
	 if [[ $line == "DELETE ME AND START" ]];
								then 
									printf "THERE IS DEFAULT TO_INSTALL ON GIT SERVER, NO TARGETS DEFINED FOR INSTALLATION, LEAVING....\n"
									return 1
                				else
                					find_policy $line   
                		    fi                   
                   done
                
else
            printf "Definition for auto-install not found, file TO_INSTALL does not exist in local git directory on FWM\n" >>$LOG
fi
}



#######################################
# MAIN CODE
# Globals:LOG, TARGETS, LOCKSCRIPT, TO_INSTALL
# checking existence of TO_INSTALL file
# DB locking
# git pull update
# running autoinstall if there is no argument with script
# if autoinstall returns 1, finishes
# finding and installing policy if script is run manually
#
#######################################
 
#if LOG exists, delete it, new one is needed
 if [[ -f "$LOG" ]];
	then
        rm -r $LOG   	
 fi

# if no argument is passed with script, lock DB, download
# definitions from git server 
if [[ "$#" -eq 0 ]];
    then
    	$LOCKSCRIPT &
        sleep 4
        db_lock
        git_pull
    
# run autoinstall, if return is 1, it means nothing has been defined for installation,
# there is default file TO_INSTALL, exiting script
# else install defined targets and update git
# if there are arguments within script, install them 

        auto_install
         if [[ "$?" -eq 1 ]];
              then 
            	  kill_dblock
                  exit 1
             else
            	 output
            	 git_push
         fi
    
  else 
    
     printf "MANUAL POLICY INSTALATION with targets as arguments...\n"
     printf "MAGIC KEYWORDS: RA , EDC, ALL, ZEN2-TEST (example:PROJECT-PROD/TEST)\n"
      $LOCKSCRIPT &
      sleep 4
      db_lock 
    	for TARGET in "$@"
    		do
    		    find_policy $TARGET
        	done
      output 
    
 fi


kill_dblock