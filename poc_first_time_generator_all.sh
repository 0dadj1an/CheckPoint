#!/bin/bash -f
#
#==============================================================================
#title      :first time generator for POC
#descrition :This script runs first time wizard and configure blades and other
#            settings
#author     :ivo.hrbacek@ixperta.com a laura
#version    :0.0001
#usage      :this script is executed and added to rc.local or if API is used can run forever and wait for interaction
# if there will be IP config via esx API, set IP of machine to 1.1.1.1 by default
# if there will be ESX API call, create LOCK file!!!!!! : /home/admin/first_time.lock
# othervise just run from cmd, it will add it automatically to /etc/rc.d/init.d/cpboot or /etc/rc.local
#==============================================================================
# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh




#variables
SCRIPTFOLDER="$( cd "$(dirname "$0")" ; pwd -P )"
FIRSTIMELOCK="$SCRIPTFOLDER/first_time.lock"
REBOOTLOCK="$SCRIPTFOLDER/reboot_lock.lock"
DONELOCK="$SCRIPTFOLDER/done_lock.lock"
LOG="$SCRIPTFOLDER/first_timelog.log"
RESTART="$SCRIPTFOLDER/restart_lock.lock"
SCRIPTFULLPATH="$SCRIPTFOLDER/poc_first_time_generator_all.sh"
REBOOTSCRIPT="$SCRIPTFOLDER/reboot.sh"
IP=1.1.1.1
A=$(/sbin/ifconfig eth1 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')
DNS1="8.8.8.8"
DNS2="8.8.4.4"
TIMESERVER="europe.pool.ntp.org"
LOGOS="$SCRIPTFOLDER/os.log"
CMD="$SCRIPTFOLDER/cmd.txt"
MONITORIF="$SCRIPTFOLDER/monitor.txt"
MGMTIF="$SCRIPTFOLDER/mgmt.txt"
MGMTMASK="$SCRIPTFOLDER/mgmtmask.txt"
MGMTIP="$SCRIPTFOLDER/mgmtip.txt"







#### OS config#####

check_logs(){

    # check LOGOS files and delete them if exists
      if [[ -f "$LOGOS" ]];
                then
                rm -r $LOGOS
                date >> $LOGOS
                printf "script starting...\n" >>$LOGOS
      fi

      if [[ -f "$CMD" ]];
                then
                rm -r $CMD
      fi

     clish -c 'lock database override' -s  >>$LOGOS
     clish -c 'set user admin shell /bin/bash' -s >> $LOGOS
     clish -c 'save config' -s >> $LOGOS
      


}


set_config(){

#set state of interfaces
echo "set interface $mgmt state on" >>$CMD
echo "set interface $monitor state on" >>$CMD
#echo "set interface eth2 state on" >>$CMD

#config interfaces
echo "set interface $monitor monitor-mode on" >>$CMD
echo "set interface $mgmt ipv4-address $ip mask-length $mask " >>$CMD
#echo "set interface eth2 ipv4-address 2.2.2.2 mask-length 24" >>$CMD
echo "set static-route default nexthop gateway address $gw on" >>$CMD
echo "set dns primary $DNS1">>$CMD
echo "set dns secondary $DNS2">>$CMD
echo "set hostname checkpointPOC" >>$CMD
echo "$mgmt" >>$MGMTIF
echo "$mask" >>$MGMTMASK
echo "$ip" >> $MGMTIP
echo "$monitor" >>$MONITORIF


}


load_parameters(){

    # load parameters and print them as template which will be loaded , if not correct after revision, it will be loaded again
    
    
    # check LOGOS fies
    check_logs

    while true;
    do
            # read data
            echo "enter management interface"
            read mgmt
            echo "enter monitor interface"
            read monitor
            echo "enter management IP"
            read ip
            echo "enter management MASK in format: 24 or 16 or 27 etc."
            read mask
            echo "enter management default gateway"
            read gw
			printf "default host name is checkpointPOC..\n"

			

            # run set method
            set_config

            
            # check rest
            printf "\n"
            printf "Printing config template:\n"
            cat $CMD
            printf "\n"
            printf "Is that correct? Write YES to continue..\n"
            read answer

            if [[ "$answer" == "YES" ]];
                then
                printf "load_parameters() is okay..\n" >> $LOGOS 
                execute_config
                else
                 printf "Loading again..\n"
                 printf "again loading parameters from load_parameters() because it was not confirmed..\n" >>$LOGOS
                 printf "removing CMD template from load_parameters()\n" >>$LOGOS
                 rm -r $CMD
                 continue
            fi
    done
}


execute_config(){

clish -c 'lock database override' -s 
clish -f /home/admin/cmd.txt 

sleep 5
printf " Write YES to continue..\n"
read answer

            if [[ "$answer" == "YES" ]];
                then
                    printf "All configured...check os.log if needed\n"
                    printf "execute_config() is okay..\n" >>$LOGOS
                    clish -c 'save config' -s >> $LOGOS
                    break
            else
                 printf "Loading again because it was not commited..\n"
                 printf "again loading parameters from execute_config() method because it was not confirmed..\n" >>$LOGOS
                 printf "removing CMD template from execute_config()\n" >>$LOGOS
                 rm -r $CMD
                 load_parameters
            fi


}



###################   end of OS config  ##########################





########## POC config ################

# default parameters setting before first_time_wizard
check_point_default_modify(){

installProductFile=/web/cgi-bin2/install_products.tcl
installProductFileTmp=install_product_tmp
importSummaryFile=/web/htdocs2/webui/ftw/ftw_import_summary.js
importSummaryFileTmp=ftw_import_summary_tmp

cp $installProductFile ${installProductFile}.backup
cp $importSummaryFile ${importSummaryFile}.backup
cp $installProductFile $installProductFileTmp
cp $importSummaryFile $importSummaryFileTmp

######requirement 5 - Must change it to fail open (under manage & settings > blades > APP&URL)#######
filePath=/web/htdocs2/webui/modifyFailOpen.sh

cat << EOF > $filePath
#!/bin/sh
psql_client cpm postgres -c "select d1.objid, d2.name from dleobjectderef_data d1, dleobjectderef_data d2 where 
d1.domainid=d2.objid and d1.dlesession=0 and not d1.deleted and d1.name='Application Control & URL Filtering Settings';" > tmp.txt
sed  '/SMC/!d' tmp.txt > tmp2.txt
ObjectName=\`sed '/SMC/!d' tmp.txt | awk -F'[|]' '{print \$(1)}'\`
mgmt_cli -r true set generic-object uid \$ObjectName gwFailure false
mgmt_cli -r true set generic-object uid \$ObjectName urlfSslCnEnabled true
EOF


deleteCmd="/bin/rm " 

#isDemoMode Section
runScript1='puts $pp "echo \\"'
runScript2='\\" >> \/etc\/rc.local"'
runScrip=$filePath 
InitdLocation='echo \\\"cpprod_util CPPROD_SetValue MGMTAPI OverrideAutoStart 1 0 1\\\"'
sed -i "/${InitdLocation}/i \
${runScript1}${filePath}${runScript2}" $installProductFileTmp
sed -i "/${InitdLocation}/i \
${runScript1}${deleteCmd}${filePath}${runScript2}" $installProductFileTmp

#isPostInstall Section
runScript1='puts $pp "'
runScript2='"'
runScrip=$filePath 
InitdLocation='puts $pp "cpprod_util CPPROD_SetValue MGMTAPI OverrideAutoStart 1 0 1"'
sed -i "/${InitdLocation}/i \
${runScript1}${filePath}${runScript2}" $installProductFileTmp
sed -i "/${InitdLocation}/i \
${runScript1}${deleteCmd}${filePath}${runScript2}" $installProductFileTmp


##########  requirement 5 - end   #########################################################################


######### requirement 6,7,8,9  ##############################
profile_conf_file_first=$FWDIR/conf/am_profiles.C
profile_conf_file_second=$FWDIR/conf/defaultDatabase/am_profiles.C
tmp_conf_file=/tmp/am_profile_tmp.C

cat $profile_conf_file_first > $tmp_conf_file

inspect_av_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 'av_settings' | grep -A0 'inspect_incoming_files_interfaces ' | cut -f1 -d: );
inspect_av_lnumber=`echo $inspect_av_lnumber | cut -c1-4`
inspect_te_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 'te_settings' | grep -A0 'inspect_incoming_files_interfaces ' | cut -f1 -d: );
inspect_te_lnumber=`echo $inspect_te_lnumber | cut -c1-4`
inspect_line="\t\t\t:inspect_incoming_files_interfaces (all)"
all_files_proactive_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 'av_settings' | grep -A0 'all_files_proactive_scan_enabled ' | cut -f1 -d: );
all_files_proactive_lnumber=`echo $all_files_proactive_lnumber | cut -c1-4`
all_files_proactive_line="\t\t\t:all_files_proactive_scan_enabled (true)"
file_type_process_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 'av_settings' | grep -A0 'file_type_process ' | cut -f1 -d: );
file_type_process_lnumber=`echo $file_type_process_lnumber | cut -c1-4`
file_type_process_line="\t\t\t:file_type_process (all_file_types)"

performance_impact_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A0 ':performance_impact ' | cut -f1 -d: );
performance_impact_lnumber=`echo $performance_impact_lnumber | cut -c1-4`
performance_impact_line="\t\t:performance_impact (high)"
performance_impact_high_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A0 ':performance_impact_high ' | cut -f1 -d: );
performance_impact_high_lnumber=`echo $performance_impact_high_lnumber | cut -c1-4`
performance_impact_high_line="\t\t:performance_impact_high (true)"

high_name_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 ':email_settings' | grep -A4 ':high_confidence' | grep -A0 'Name' | cut -f1 -d: );
high_name_lnumber=`echo $high_name_lnumber | cut -c1-4`
high_uid_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 ':email_settings' | grep -A4 ':high_confidence' | grep -A0 'Uid' | cut -f1 -d: );
high_uid_lnumber=`echo $high_uid_lnumber | cut -c1-4`

med_name_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A70 ':email_settings' | grep -A4 ':medium_confidence' | grep -A0 'Name' | cut -f1 -d: );
med_name_lnumber=`echo $med_name_lnumber | cut -c1-4`
med_uid_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A70 ':email_settings' | grep -A4 ':medium_confidence' | grep -A0 'Uid' | cut -f1 -d: );
med_uid_lnumber=`echo $med_uid_lnumber | cut -c1-4`

detect_line="\t\t\t:Name (Detect)"
uid_line="\t\t\t:Uid (\"{5D5500C7-BDCB-42EB-BB49-AD4EE802F62C}\")"

sed -i "${inspect_av_lnumber}s/.*/$inspect_line/" $tmp_conf_file
sed -i "${inspect_te_lnumber}s/.*/$inspect_line/" $tmp_conf_file
sed -i "${all_files_proactive_lnumber}s/.*/$all_files_proactive_line/" $tmp_conf_file
sed -i "${file_type_process_lnumber}s/.*/$file_type_process_line/" $tmp_conf_file
sed -i "${performance_impact_lnumber}s/.*/$performance_impact_line/" $tmp_conf_file
sed -i "${performance_impact_high_lnumber}s/.*/$performance_impact_high_line/" $tmp_conf_file
sed -i "${high_name_lnumber}s/.*/$detect_line/" $tmp_conf_file
sed -i "${high_uid_lnumber}s/.*/$uid_line/" $tmp_conf_file
sed -i "${med_name_lnumber}s/.*/$detect_line/" $tmp_conf_file
sed -i "${med_uid_lnumber}s/.*/$uid_line/" $tmp_conf_file

cp $profile_conf_file_first ${profile_conf_file_first}.backup
cp $profile_conf_file_second ${profile_conf_file_second}.backup
cp $tmp_conf_file $profile_conf_file_first
cp $tmp_conf_file $profile_conf_file_second
rm $tmp_conf_file

##########################################################


######requirement 3,13  - remove child abuse rule + add new rule that will remove FW logs#################

	#isDemoMode Section
	origLine='Block Child Abuse sites\\\\\\" service \\\\\\"Child Abuse\\\\\\" action drop'
	newLine='for app url connections\\\\\\" destination Internet track.type \\\\\\"Detailed Log\\\\\\" track.accounting true action accept'
	nextLineStart='puts $pp "echo \\"'
	nextLine='mgmt_cli set access-rule layer Network name \\\\\\"for app url connections\\\\\\" track.per-connection false'
	nextLineEnd=' -s /tmp/sid >> /var/log/ftw_install.log 2>&1\\" >> /etc/rc.local"'
	origLine1='threat-emulation false anti-bot false anti-virus false'
	newLine1='threat-emulation true anti-bot true anti-virus true'
	#replace text
	sed -i "s/${origLine}/${newLine}/" $installProductFileTmp
	sed -i "/${newLine}/a ${nextLineStart}${nextLine}${nextLineEnd}" $installProductFileTmp
	sed -i '/ProtocolsLogging/d' $installProductFileTmp
	sed -i "s/${origLine1}/${newLine1}/" $installProductFileTmp
	
	#isPostInstall Section
	origLine='Block Child Abuse sites\\\" service \\\"Child Abuse\\\" action drop'
	newLine='for app url connections\\\" destination Internet track.type \\\"Detailed Log\\\" track.accounting true action accept'
	nextLineStart='puts $pp "'
	nextLine='mgmt_cli set access-rule layer Network name \\\"for app url connections\\\" track.per-connection false'
	nextLineEnd=' -s /tmp/sid >> /var/log/ftw_install.log 2>&1"'
	origLine1='threat-emulation false anti-bot false anti-virus false'
	newLine1='threat-emulation true anti-bot true anti-virus true'
	#replace text
	sed -i "s/${origLine}/${newLine}/" $installProductFileTmp
	sed -i "/${newLine}/a ${nextLineStart}${nextLine}${nextLineEnd}" $installProductFileTmp
	sed -i '/ProtocolsLogging/d' $installProductFileTmp
	sed -i "s/${origLine1}/${newLine1}/" $installProductFileTmp
######   requirement 3,13  - end ##############################################################################



###### kfirY additions ######
	#change track to track.type
	sed -i "s/AcceptAll action accept track none/AcceptAll action accept track.type none/" $installProductFileTmp
	mv $installProductFileTmp $installProductFile

	#install eventia
	sed -i 's/install_eventia: false/install_eventia: true/' $importSummaryFileTmp
	mv $importSummaryFileTmp $importSummaryFile
##### kfirY additions - end #####################

chmod -R 755 $filePath
chmod -R 755 $importSummaryFile
chmod -R 755 $installProductFile        
}





#set rights for script itself and add to rc.local
set_rights_and_rclocal(){
printf "###################\n" >>$LOG
printf "set rights to script\n" >>$LOG
chown -v admin:bin $SCRIPTFULLPATH  >>$LOG
chmod -v u=rwx,g=rwx,a=rwx $SCRIPTFULLPATH >>$LOG
echo $SCRIPTFULLPATH >> /etc/rc.local
cat /etc/rc.local >> $LOG
printf "###################\n" >>$LOG

}





# check api status
check_api(){

	count=0
    printf "###################\n" >>$LOG
	printf "check api status\n" >>$LOG
	while true;
	do
	sleep 60
	mgmt_cli login -r true > /home/admin/id.txt
	a=$?
	count = count+1

	if [[ "$a" -eq 1 ]];
       then
	       printf "API not loaded...\n">>$LOG
		   if [[ "$a" -eq 11 ]];
               then
			   count=0
			   api restart
		   fi
			    
	    continue
    else
	    printf "API loaded\n">>$LOG 
	    break
    fi
	done
printf "###################\n" >>$LOG
}






# method for first time wizard settings

run_wizard(){

	
#basic kernel modification, disable antispoofing and other stuff according to POC gide	
echo "fw_local_interface_anti_spoofing=0" >> $FWDIR/modules/fwkern.conf
echo "fw_antispoofing_enabled=0" >> $FWDIR/modules/fwkern.conf
echo "sim_anti_spoofing_enabled=0" >> $FWDIR/modules/fwkern.conf
echo "fw_icmp_redirects=1" >> $FWDIR/modules/fwkern.conf
echo "fw_allow_out_of_state_icmp_error=1" >> $FWDIR/modules/fwkern.conf
echo "psl_tap_enable=1" >> $FWDIR/modules/fwkern.conf
echo "fw_tap_enable=1" >> $FWDIR/modules/fwkern.conf


#run basic first time wizard
/bin/config_system -s 'install_security_managment=true&install_mgmt_primary=true&install_mgmt_secondary=false&install_security_gw=true&mgmt_gui_clients_radio=any&mgmt_admin_name=admin&mgmt_admin_passwd=checkpoint123&hostname=checkpointPOC&ntp_primary=europe.pool.ntp.org&primary=8.8.8.8&download_info=true&timezone=Europe/Vienna' 
a=$? 
if [[ "$a" -eq 1 ]];
 then 
        printf "firsttime wizard crashed, run it again\n" >>$LOG
        exit 1
 else
        echo "rebootfile created after first_time wizard\n" > $REBOOTLOCK && echo "reboot lock" > $RESTART  && printf "firsttime wizard success!!!\n" >>$LOG && printf "######################################\n" >>$LOG 
		exit 0
		
        	        
fi
}





# method for fw configuration
set_settings(){

#wait till API server will start	
check_api	



printf "######################################\n" >>$LOG
printf "configuring simple gateway blades, Layer and adding Allow rule + log..\n" >>$LOG
mgmt_cli set simple-gateway name "checkpointPOC" firewall true application-control true url-filtering true ips true anti-bot true anti-virus true threat-emulation true content-awareness true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
# dodelej Layer Network a aktivuj app/ atd
mgmt_cli set access-layer name "Network" applications-and-url-filtering true data-awareness true detect-using-x-forward-for true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
mgmt_cli publish -s /home/admin/id.txt >>$LOG 2>>$LOG
c=$?

mgmt_cli add access-rule layer "Network" position 1 name "Rule 1" action "Accept" track-settings.type "Detailed Log" track-settings.accounting "True" track-settings.per-connection "True" track-settings.per-session "True"  --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG

mgmt_cli set access-rule name "Cleanup rule" layer "Network" enabled "False"  --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG

printf "######################################\n" >>$LOG


# not needed, already done for Optimized profile in method checkpoint_default_modify()
#printf "TP policy and rules..\n" >>$LOG
#mgmt_cli add threat-profile name "POC" active-protections-performance-impact "High" active-protections-severity "Low or above" confidence-level-high "Detect" confidence-level-low "Detect" confidence-level-medium "Detect" threat-emulation true anti-virus true anti-bot true ips true ips-settings.newly-updated-protections "active" --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG

#mgmt_cli set threat-rule rule-number 1 layer "Standard Threat Prevention" comments "commnet for the first rule" protected-scope "Any" action "POC" install-on "Policy Targets" --format json -s /home/admin/id.txt >>$LOG 2>>$LOG

#printf "######################################\n" >>$LOG

printf "######################################\n" >>$LOG
printf "Aditional blade settings..\n" >>$LOG
# aditional settings
# get CP object UID in a variable
a=$(mgmt_cli -r true show simple-gateway name checkpointPOC | grep "uid" | head -1  | awk -F':' '{ gsub(" ", "", $0 ); print $2 }')
# other possible way ho to do that
#mgmt_cli set generic-object uid $(mgmt_cli -r true show simple-gateway name checkpointPOC | grep "uid" | head -1  | awk -F':' '{ gsub(" ", "", $0 ); print $2 }') enableRtmTrafficReportPerConnection true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG


# monitoring blade
mgmt_cli set generic-object uid $a realTimeMonitor true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
mgmt_cli set generic-object uid $a enableRtmTrafficReportPerConnection true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
mgmt_cli set generic-object uid $a enableRtmTrafficReport true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
mgmt_cli set generic-object uid $a enableRtmCountersReport true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG

#indexing
mgmt_cli set generic-object uid $a logIndexer true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
#correlation unit
mgmt_cli set generic-object uid $a eventAnalyzer true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
#smartevent server
mgmt_cli set generic-object uid $a abacusServer true --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG

#rest unused, just for testing
#mgmt_cli -r true set generic-object uid $a smarteventIntro true >>$LOG 2>>$LOG
#mgmt_cli -r true set generic-object uid $a ipsEventCorrelator true >>$LOG 2>>$LOG
#mgmt_cli -r true set generic-object uid $a ipsEventManager true >>$LOG 2>>$LOG

# topology definition 
mgmt_cli add simple-gateway name "checkpointPOC" interfaces.1.name $(cat $MGMTIF) interfaces.1.ipv4-address $(cat $MGMTIP) interfaces.1.ipv4-mask-length $(cat $MGMTMASK) interfaces.1.topology internal interfaces.2.name $(cat $MONITORIF) interfaces.2.ipv4-address 0.0.0.0 interfaces.2.ipv4-mask-length 32 interfaces.2.topology external --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG

printf "######################################\n" >>$LOG
printf "IPS update..\n" >>$LOG
mgmt_cli run-ips-update -s /home/admin/id.txt >>$LOG 2>>$LOG
#sleep 10


printf "######################################\n" >>$LOG
#publish
mgmt_cli publish -s /home/admin/id.txt >>$LOG 2>>$LOG >>$LOG 2>>$LOG
b=$?
#sleep 10
printf "######################################\n" >>$LOG

printf "######################################\n" >>$LOG
printf "Policy install..\n" >>$LOG
mgmt_cli install-policy policy-package "Standard" access true threat-prevention false targets.1 "checkpointPOC" --format json -s /home/admin/id.txt >>$LOG 2>>$LOG
#sleep 10
mgmt_cli install-policy policy-package "Standard" access false threat-prevention true targets.1 "checkpointPOC" --format json -s /home/admin/id.txt >>$LOG 2>>$LOG
#sleep 10
printf "######################################\n" >>$LOG

#check status of publish..
if [[ "$c" -eq 1 ]] || [[ "$b" -eq 1 ]];
 then
	printf "######################################\n"	 >>$LOG 
	printf "firewall settings crashed, run it again\n"  >>$LOG 
	printf "######################################\n" >>$LOG 
	exit 1
 else
	printf "######################################\n"	 >>$LOG 
	printf "settings success!!!\n" >>$LOG 
	printf "######################################\n" >>$LOG 
	echo "donefile created after first_time wizard, do not delete manually\n" > $DONELOCK
	rm -r $REBOOTLOCK
	mgmt_cli logout -s /home/admin/id.txt >>$LOG 2>>$LOG
	sleep 10
	/sbin/shutdown -r now >>$LOG 2>>$LOG
	exit 0
fi
}






main_check(){
  while true;
 # loop checking lock files to make appropriate configs
  do
	
        #existuje FIRSTIMELOCK a zaroven neexistuje REBOOTLOCK
        if [[ -f "$FIRSTIMELOCK" ]] && [[ ! -f "$REBOOTLOCK" ]];
                then	
                continue
        fi

        #neexistuje FIRSTIMELOCK a neexistuje REBOOTLOCK a neexistuje DONELOCK
        if [[ ! -f "$FIRSTIMELOCK" ]] && [[ ! -f "$REBOOTLOCK" ]] && [[ ! -f "$DONELOCK" ]];
                then
				# call OS config
                load_parameters
				# set basic settings
				check_point_default_modify
				# set rights for script
				set_rights_and_rclocal
				# run firt time wizard
                run_wizard
        fi

        #existuje REBOOTLOCK a zaroven neexistuje FIRSTTIME
        if [[ -f "$REBOOTLOCK" ]] && [[ ! -f "$FIRSTIMELOCK" ]];
                then
                set_settings
        fi

        #existuje done lock tak se vypni uplne
        if [[ -f "$DONELOCK" ]];
                then
        printf "first time wizard and settings done, not needed to run\n" >>$LOG 
                exit 1
        fi

  done
}







# first idea of this method was to catch change on OS level and start first time wizard - IP will be changed via ESX API, but no way on ESXi - remains because it does not
# bring any problems
ip_checker(){
	
while true;
do
	A=$(/sbin/ifconfig eth1 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')
	if [[ "$IP" == "$A" ]];
        then
                sleep 5
                rm -r $LOG >/dev/null 2>/dev/null
                continue              
	fi
	#printf "IP changed, removing lock file\n" >>$LOG
	rm -r /home/admin/first_time.lock >/dev/null 2>/dev/null
	printf "entering main check\n" >>$LOG
	main_check

done
	
}

###################   end of POC config  ##########################


#MAIN CODE BLOCK - just run ip_checker

#initial log
printf "################################\n" >>$LOG 
printf "Starting script..\n">>$LOG 

# settings
ip_checker