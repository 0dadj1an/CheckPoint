#!/bin/bash
# scrip for OS level config details
#ivosh


DNS1="8.8.8.8"
DNS2="8.8.4.4"
TIMESERVER="europe.pool.ntp.org"
LOG=/home/admin/os.log
CMD=/home/admin/cmd.txt




load_parameters(){
bash /home/admin/initial_scripts/checkpoint_poc_modify.sh
rm -r $LOG
echo "enter management interface"
read mgmt
echo "enter monitor interface"
read monitor
echo "enter management IP"
read ip
echo "enter management MASK"
read mask
echo "enter management default gateway"
read gw


}

set_config(){

#set state of interfaces
echo "set interface $mgmt state on" >>$CMD
echo "set interface $monitor state on" >>$CMD	
echo "set interface eth2 state on" >>$CMD

#config interfaces
echo "set interface $monitor monitor-mode on" >>$CMD
echo "set interface $mgmt ipv4-address $ip mask-length $mask " >>$CMD
echo "set interface eth2 ipv4-address 2.2.2.2 mask-length 24" >>$CMD
echo "set static-route default nexthop gateway address $gw on" >>$CMD
echo "set dns primary $DNS1">>$CMD
echo "set dns secondary $DNS2">>$CMD
echo "set hostname checkpoint" >>$CMD

clish -f /home/admin/cmd.txt >>$LOG
clish -c 'show hostname' -s >>$LOG

rm -r $CMD
}

load_parameters
set_config


