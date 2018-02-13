#!/bin/bash
#
#==============================================================================
#title      :first time generator
#descrition :This script runs first time wizard and configure blades and other
#            settings
#author     :ivo.hrbacek@ixperta.com
#version    :0.0001
#usage      :this script is executed after boot via rc.local
# set IP of machine to 1.1.1.1 by default
# create LOCK file!!!!!! : /home/admin/first_time.lock
#
#==============================================================================
# CP enviroment variables for cron see sk77300, sk90441

#variables
FIRSTIMELOCK=/home/admin/first_time.lock
REBOOTLOCK=/home/admin/reboot_lock.lock
DONELOCK=/home/admin/done_lock.lock
LOG=/home/admin/first_timelog.log
IP=1.1.1.1
A=$(/sbin/ifconfig eth1 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')

check_point_default_modify(){
        
}

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
/bin/config_system -s 'install_security_managment=true&install_mgmt_primary=true&install_mgmt_secondary=false&install_security_gw=true&mgmt_gui_clients_radio=any&mgmt_admin_name=admin&mgmt_admin_passwd=checkpoint123&hostname=checkpoint&ntp_primary=europe.pool.ntp.org&primary=8.8.8.8&download_info=true&timezone=Europe/Vienna' 
a=$? 
if [[ "$a" -eq 1 ]];
 then
        printf "######################################\n" >>$LOG
        printf "firsttime wizard crashed, run it again\n" >>$LOG
        printf "######################################\n" >>$LOG
        exit 1
 else
        printf "######################################\n" >>$LOG
        printf "firsttime wizard success!!!\n"  >>$LOG
        printf "######################################\n" >>$LOG
        echo "rebootfile created after first_time wizard\n" > $REBOOTLOCK
        sleep 10
        shutdown -r now
        exit 0
fi
}



set_settings(){
#wait till API server will start	
sleep 240	
mgmt_cli login -r true > /home/admin/id.txt
sleep 10
mgmt_cli set simple-gateway name "checkpoint" firewall true application-control true url-filtering true ips true anti-bot true anti-virus true threat-emulation false --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
sleep 10
mgmt_cli add access-rule layer "Network" position 1 name "Rule 1" action "Accept" track "Log" --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
sleep 10
mgmt_cli set access-rule name "Cleanup rule" layer "Network" enabled "False"  --format json ignore-warnings true -s /home/admin/id.txt >>$LOG 2>>$LOG
sleep 10
mgmt_cli publish -s /home/admin/id.txt >>$LOG 2>>$LOG
a=$?
sleep 10
mgmt_cli install-policy policy-package "Standard" access true targets.1 "checkpoint" --format json -s /home/admin/id.txt >>$LOG 2>>$LOG
sleep 30
mgmt_cli install-policy policy-package "Standard" threat-prevention true targets.1 "checkpoint" --format json -s /home/admin/id.txt >>$LOG 2>>$LOG
sleep 30

if [[ "$a" -eq 1 ]];
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
	shutdown -r now	
	exit 0
fi
}


main_check(){
  while true;
 # loop checking lock files
  do
	
        #existuje FIRSTIMELOCK a zaroven neexistuje REBOOTLOCK
        if [[ -f "$FIRSTIMELOCK" ]] && [[ ! -f "$REBOOTLOCK" ]];
                then	
                continue
        fi

        #neexistuje FIRSTIMELOCK a neexistuje REBOOTLOCK a neexistuje DONELOCK
        if [[ ! -f "$FIRSTIMELOCK" ]] && [[ ! -f "$REBOOTLOCK" ]] && [[ ! -f "$DONELOCK" ]];
                then
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
	printf "IP changed, removing lock file\n" >>$LOG
	rm -r /home/admin/first_time.lock >/dev/null 2>/dev/null
	printf "entering main check\n" >>$LOG
	main_check

done
	
}

#MAIN CODE
#
#lock creation 

#initial log
printf "Local IP is $A\n"	>>$LOG 
ip_checker



