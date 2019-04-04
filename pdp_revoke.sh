
#!/bin/bash -f
#
#==============================================================================
#title	    :pdp revoke script
#descrition :This script search for user with no role and doing revoke
#author	    :ivo.hrbacek
#version    :0.0001
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


now=$(date)

# get count of users with no roles
count=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  | wc -l)



# if 0 do nothing, else do the magic
if [[ "$count" == "0" ]]; 
     then
           printf "doing nothing..\n"  >/dev/null 2>&1
     
     else
          printf "###################\n" >> /home/admin/IA_revoke/revoke.log
          printf "date is: $now\n" >> /home/admin/IA_revoke/revoke.log
          printf "count is: $count\n"  >> /home/admin/IA_revoke/revoke.log

          printf "running..\n"  >> /home/admin/IA_revoke/revoke.log

          ip=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  |  awk -F@ '{print $1}'); for item in $a; do echo "$(pdp mon user $item | egrep -o '([0-9]+\.){3}[0-9]+')" ; done  >> /home/admin/IA_revoke/revoke.log
          

          if [[ -z "$ip" ]]; 
              then
                    printf "no data for revoke found\n"  >/dev/null 2>&1
          else
               printf "data for revocation are:\n"  >> /home/admin/IA_revoke/revoke.log
               printf "$ip\n"  >> /home/admin/IA_revoke/revoke.log

              d=$(a=$(pdp mon all | grep -v  "Groups: All" | grep Users: -A 4 | grep -B 4 "Client Type: Identity Collector" | grep -B 2 "Roles: -" | grep -v "Roles: -" | grep -v "Groups: " | grep -v "-"  |  awk -F@ '{print $1}'); for item in $a; do echo "$(pdp mon user $item | egrep -o '([0-9]+\.){3}[0-9]+')" ; done); for item02 in $d; do pdp control revoke_ip $item02; done >> /home/admin/IA_revoke/revoke.log
              printf "###################\n"  >> /home/admin/IA_revoke/revoke.log
          fi


fi
