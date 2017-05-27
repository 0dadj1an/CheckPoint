#!/bin/bash
#
#==============================================================================
#title      :gw settings analyzer
#descrition :This script runs multiple commands to catch system conf status
#author     :ivo.hrbacek@ixperta.com
#version    :0.0001
#usage      :change admin shell to bash by: set user admin shell /bin/bash or enter expert mode
#           :add execution by chmod +x analyzator.sh and run it
#           :send fw_output
#==============================================================================
# CP enviroment variables for cron see sk77300, sk90441
#
NAME=''
LOG="/home/admin/$(hostname).log"

print_format(){
printf "########################\n" >>$LOG 2>>$LOG
}

run_commands(){
print_format 

#os
date >>$LOG 2>>$LOG
print_format
top -n 1 -b >>$LOG 2>>$LOG
print_format
df -h >>$LOG 2>>$LOG
print_format
free -m -t >>$LOG 2>>$LOG
print_format
cat /proc/cpuinfo >>$LOG 2>>$LOG
print_format
cat /proc/meminfo >>$LOG 2>>$LOG
print_format
ps auxw >>$LOG 2>>$LOG
print_format
fw ver -k >>$LOG 2>>$LOG
print_format
installed_jumbo_take >>$LOG 2>>$LOG
print_format
cpinfo -y all >>$LOG 2>>$LOG
print_format
fw stat >>$LOG 2>>$LOG
print_format



#ha
cphaprob state >>$LOG 2>>$LOG
print_format
cphaprob list >>$LOG 2>>$LOG
print_format
 
#l1
netstat -ni >>$LOG 2>>$LOG
print_format
dmesg | grep -i "table overflow" >>$LOG 2>>$LOG
print_format
arp -an | wc -l >>$LOG 2>>$LOG
print_format 
ifconfig >>$LOG 2>>$LOG
print_format 
route -n >>$LOG 2>>$LOG
print_format 

#conn table
print_format
fw tab -t connections | grep limit >>$LOG 2>>$LOG
print_format
fw tab -t connections -s >>$LOG 2>>$LOG
print_format
fw tab -t fwx_cache -s >>$LOG 2>>$LOG
print_format 

#secxl
print_format
fw ctl pstat >>$LOG 2>>$LOG
print_format
fwaccel stat >>>>$LOG 2>>$LOG
print_format
fwaccel stats >>$LOG 2>>$LOG
print_format
fwaccel stats -s >>$LOG 2>>$LOG
print_format
fwaccel stats -p >>$LOG 2>>$LOG
print_format 

#core
print_format
cat /proc/interrupts >>$LOG 2>>$LOG
print_format
fw -d ctl affinity -corelicnum >>$LOG 2>>$LOG
print_format
fw ctl affinity -l >>$LOG 2>>$LOG
print_format
fw ctl multik stat >>$LOG 2>>$LOG
print_format
cpmq get -a >>$LOG 2>>$LOG	

sleep 5
}


printf "Executing and collecting data to log file $LOG, script does not change anything in config!\n"
run_commands

