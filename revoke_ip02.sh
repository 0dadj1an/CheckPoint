#!/bin/bash -f
#
#==============================================================================
#title	    :pdp revoke script
#descrition :This script search for user with no role and doing revoke
#author	    :ivo.hrbacek
#version    :0.0001 (shitty one since writing when debuging)
# running via cpd_sched_config 

#add task:
#cpd_sched_config add IA_revoke_ip -c "/bin/bash /home/admin/IA_revoke/revoke_ip.sh" -r -s -e 60


#check task:
#cpd_sched_config print

#del task:
#cpd_sched_config delete IA_revoke_ip
#
#
#==============================================================================

source /opt/CPshrd-R80.20/tmp/.CPprofile.sh


DEBUG_FILE=/home/admin/IA_revoke/debug.txt



off_debug() {

if [ -f "$DEBUG_FILE" ]; 
    then
        date01=$(date)
        printf "$DEBUG_FILE exist, wont do any debug off task :$date01\n" >> /home/admin/IA_revoke/revoke.log
    else
      
      printf "creating debug file and waiting 60 seconds" > /home/admin/IA_revoke/debug.txt
      #sleep 60
      date=$(date)
      printf "TURNING OFF DEBUG NOW :$date\n" >> $FWDIR/log/pdpd.elg
      printf "TURNING OFF DEBUG NOW :$date\n" >> $FWDIR/log/pepd.elg
      printf "turning off pep and pdp debug at $date \n" >> /home/admin/IA_revoke/revoke.log

      printf "$(pdp d unset all all; pdp debug off; printf "\n" >>/home/admin/IA_revoke/revoke.log;find $FWDIR/log/ -type f -name 'pdpd.*' -exec cat {} + >> /home/admin/IA_revoke/debug.txt)" >> /home/admin/IA_revoke/revoke.log
      printf "$(pep d unset all all; pep debug off; printf "\n" >>/home/admin/IA_revoke/revoke.log;find $FWDIR/log/ -type f -name 'pepd.*' -exec cat {} + >> /home/admin/IA_revoke/debugpep.txt)" >> /home/admin/IA_revoke/revoke.log

fi

}



main() {

now=$(date)

#printf "$now\n" >> /home/admin/IA_revoke/revoke.log

# get count of users with no roles
count=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-" | wc -l)



# if 0 do nothing, else do the magic
if [[ "$count" == "0" ]]; 
     then
           printf "doing nothing..\n"  >/dev/null 2>&1
           
           
     
     else
          #printf "test\n" >> /home/admin/IA_revoke/revoke.log  
          user=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  |  awk -F@ '{print $1}') 
          
          

          if [[ -z "$user" ]]; 
              then
                    printf "no collector identity for revoke found, only agent, wont revoke it\n" >/dev/null 2>&1
          else
               printf "###################\n" >> /home/admin/IA_revoke/revoke.log
               printf "date is: $now\n" >> /home/admin/IA_revoke/revoke.log
               printf "count is: $count\n"  >> /home/admin/IA_revoke/revoke.log
               printf "running..\n"  >> /home/admin/IA_revoke/revoke.log
               printf "users for revocation are:\n"  >> /home/admin/IA_revoke/revoke.log
               printf "$user\n"  >> /home/admin/IA_revoke/revoke.log
               printf "\n"
               printf "#### user data####\n" >> /home/admin/IA_revoke/revoke.log
               c=$(a=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  |  awk -F@ '{print $1}'); for item in $a; do echo "$(pdp mon user $item)" >> /home/admin/IA_revoke/revoke.log ; done)
               printf"\n">> /home/admin/IA_revoke/revoke.log
               printf "##pep data for users##:\n"  >> /home/admin/IA_revoke/revoke.log
               q=$(a=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  |  awk -F@ '{print $1}'); for item in $a; do echo "$(pep show user query usr $item)" >> /home/admin/IA_revoke/revoke.log ; done)
               printf "##pep data finish##"
               printf "#### user data finish####\n" >> /home/admin/IA_revoke/revoke.log
               printf "\n" >> /home/admin/IA_revoke/revoke.log
               printf "doing update specific..\n"  >> /home/admin/IA_revoke/revoke.log
               d2=$(a=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  |  awk -F@ '{print $1}'); for item in $a; do echo "$(pdp update specific $item)" ; done) >> /home/admin/IA_revoke/revoke.log           
               printf "#### user data after update####\n" >> /home/admin/IA_revoke/revoke.log
               g=$(a=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  |  awk -F@ '{print $1}'); for item in $a; do echo "$(pdp mon user $item)" >> /home/admin/IA_revoke/revoke.log ; done)
               printf "#### user data after update  finish####\n" >> /home/admin/IA_revoke/revoke.log
               printf "calling debug off because user $user found with no role\n" >> /home/admin/IA_revoke/revoke.log
               off_debug
              #printf "### doing pdp update all##\n" >> /home/admin/IA_revoke/revoke.log
              #printf "$(pdp update all)\n" >> /home/admin/IA_revoke/revoke.log
              #printf "finish pdp update all\n" >> /home/admin/IA_revoke/revoke.log
              #printf "checking user once again\n">> /home/admin/IA_revoke/revoke.log
              #c=$(a=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v     "-"  |  awk -F@ '{print $1}'); for item in $a; do echo "$(pdp mon user $item)" >> /home/admin/IA_revoke/revoke.log ; done)
               #printf "\n"
               # make sure you wont revoke IP which learned also via Agent, remove just IP when collector data presented with no role!!
               printf "doing revoke for sure:\n" >> /home/admin/IA_revoke/revoke.log
               d=$(a=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  |  awk -F@ '{print $1}'); for item in $a; do echo "$(if pdp mon user $item | grep -q "Agent"; then echo "Agent"; else pdp mon user $item | egrep -o '([0-9]+\.){3}[0-9]+'; fi)"; done); for item02 in $d; do pdp control revoke_ip $item02; done >> /home/admin/IA_revoke/revoke.log     
               printf "revoke done\n" 
               printf "###################\n"  >> /home/admin/IA_revoke/revoke.log
          fi


fi

}

main
