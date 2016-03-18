# CheckPoint Policy Autoinstall
this is examle of script which do auto installation of firewall policies on versions R77

script can run via cron or manually from command line

script work together with git client, please keep in mind that base Gaia OS does not have git client, you have to compile it

please note that script code is limited to show you finding policy in database and installing shared policy on multiple clusters, my original code in production is large and can not be shared, it should act as reference

see code comments!

important method find_policy:
 
using help file dbedit.txt for definition of magic command for dbedit (skI3301)  
dbedit than search for table where is located name of cluster and policy name.. waiting for R80 API to avoid these magics :) 

example: 
print install_state_details xxxx        where xxx is name of firewall cluster, will print info about cluster

sorting and getting policy name by:

dbedit -local -f dbedit.txt | grep policy_name | sort -u | awk -F':' '{ gsub(" ", "", $0 ); print $2 }'



important method install_policy:

calling fwm load for policy installation 

example:

fwm load $FWDIR/conf/Standart.W" clusterA


