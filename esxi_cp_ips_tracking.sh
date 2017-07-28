#! /bin/sh
#
#==============================================================================
#title	    :tracking script
#descrition :scrip trackimg mgmt IP of IPS box and if unavailable, it will shutdown interfaces to perform failover on ASA fw
#author	    :ivo.hrbacek@ixperta.com
#version    :0.1
#usage	    :this script is executed via rc.local after esx boot
#            can be executed also manually 

#==============================================================================

CHECKER=0

while true;
do
        host=10.10.73.32
        PING=$(ping -c 5 $host | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                if [ $PING -eq 0 ]; then
                        
                        PING02=$(ping -c 4 $host | grep received | cut -d ',' -f2 | cut -d ' ' -f2)

                                if [ $PING02 -eq 0 ]; then
                                        if [ $CHECKER -eq 0 ]; then
                                        date >> /ips_tracking.log
                                        echo "Shuting down interfaces vmnic6 and vmnic7" >>/ips_tracking.log
                                        esxcli network nic down -n vmnic6
                                        esxcli network nic down -n vmnic7
                                        echo "###"
                                        CHECKER=1
                                        fi
                                fi
                else
                        if [ $CHECKER -eq 1 ]; then
                        		date >> /ips_tracking.log
                                echo "Enabling interfaces vmnic6 and vmnic7"
                                esxcli network nic up -n vmnic7
                                esxcli network nic up -n vmnic6
                                CHECKER=0

                        fi
                fi
sleep 1
done


###
#inside vmware needs to be because vmware will delete custom scrpts
#
#/etc/rc.local.d/local.sh
#[root@localhost:/etc/rc.local.d] cat local.sh
#!/bin/sh

# local configuration options

# Note: modify at your own risk!  If you do/use anything in this
# script that is not part of a stable API (relying on files to be in
# specific places, specific tools, specific output, etc) there is a
# possibility you will end up with a broken system after patching or
# upgrading.  Changes are not supported unless under direction of
# VMware support.

# Note: This script will not be run when UEFI secure boot is enabled.

#after reboot shutdown IPS interfaces before machine will be running
esxcli network nic down -n vmnic6
esxcli network nic down -n vmnic7


#run IPS tracking script
#
#==============================================================================
#title      :tracking script
#descrition :scrip trackimg mgmt IP of IPS box and if unavailable, it will shutdown interfaces to perform failover on ASA fw
#author     :ivo.hrbacek@ixperta.com
#version    :0.1
#usage      :this script is executed via rc.local after esx boot
#            can be executed also manually

#==============================================================================

CHECKER=0

while true;
do
        host=10.10.73.32
        PING=$(ping -c 4 $host | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                if [ $PING -eq 0 ]; then

                        PING02=$(ping -c 4 $host | grep received | cut -d ',' -f2 | cut -d ' ' -f2)

                                if [ $PING02 -eq 0 ]; then
                                        if [ $CHECKER -eq 0 ]; then
                                        date >> /ips_tracking.log
                                        echo "Shuting down interfaces vmnic6 and vmnic7" >> /ips_tracking.log
                                        esxcli network nic down -n vmnic6
                                        esxcli network nic down -n vmnic7
                                        echo "###" >> /ips_tracking.log
                                        CHECKER=1
                                        fi
                                fi
                else
                        if [ $CHECKER -eq 1 ]; then
                                date >> /ips_tracking.log
                                echo "Enabling interfaces vmnic6 and vmnic7" >> /ips_tracking.log
                                esxcli network nic up -n vmnic7
                                esxcli network nic up -n vmnic6
                                CHECKER=0

                        fi
                fi
sleep 1
done

[root@localhost:/etc/rc.local.d]

#
#
###
