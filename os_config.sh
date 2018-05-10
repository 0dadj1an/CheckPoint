
#!/bin/bash -f
#
#==============================================================================
#title      :first time generator for POC help sritpt for loading basic config data
#author     :ivo.hrbacek@ixperta.com a laura
#version    :0.0001
# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh



DNS1="8.8.8.8"
DNS2="8.8.4.4"
TIMESERVER="europe.pool.ntp.org"
LOGOS=/home/admin/os.log
CMD=/home/admin/cmd.txt

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
echo "set hostname checkpoint" >>$CMD

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
                    printf "All configured...\n"
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


# MAIN block, caling functions one by one

load_parameters


