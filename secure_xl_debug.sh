#!/bin/bash

nastav_kernel_secure_xl(){

echo "NASTAVENI KERNEL PARAMETRU:"

fw ctl set int fwha_print_all_drops 1
a=$?
fw ctl set int fwha_dprint_io 1
b=$?

if [[ "$a" -eq 1  ]] || [[ "$b" -eq 1 ]];
 then
    printf "nastaveni se nezdarilo!!!\n"

 else
    printf "nastaveni je v poradku\n"
    printf "#########################\n"
    sleep 1

fi

}

nastav_tcpdump_a_monitor(){

echo "NASTAVENI TCPDUMP A FW_MONITOR:"

#tcpdump -s0 -i <interface_facing_client> host <HOST_IP> -w /var/log/client.pcap  &
tcpdump -s0 -i eth2 host 192.168.10.5 -w /var/log/client.pcap  &
a=$?

#tcpdump -s0 -i <interface_facing_destination> host <HOST_IP> -w /var/log/destination.pcap &
tcpdump -s0 -i eth3 host 192.168.10.5 -w /var/log/destination.pcap &
b=$?

fw monitor -e "host(192.168.10.5) and host(8.8.8.8), accept;" -o /var/log/fw_mon.cap &
c=$?

sleep 2
}


nastav_debug_secure_xl(){

echo "\n"
echo "NASTAVUJI DEBUG"

fw ctl debug 0
a=$?
fw ctl debug -buf 32000
b=$?
fw ctl debug -m fw + conn drop vm monitor
c=$?
fwaccel dbg -m general + drop del  notif
d=$?
fwaccel dbg -m db + add del tcpstate template
e=$?
fwaccel dbg -m timer + expire
f=$?
fwaccel dbg -m api + add del reset
g=$?
sim dbg -m pkt + drop notif pkt pxl tcpstate
h=$?
sim dbg -m db + del tmo
i=$?
sim dbg -m drv + pkt
j=$?

if [[ "$a" -eq 1 ]]  ||  [[ "$b" -eq 1 ]]  ||  [[ "$c" -eq 1 ]] ||  [[ "$d" -eq 1 ]] ||  [[ "$e" -eq 1 ]] ||  [[ "$f" -eq 1 ]] ||  [[ "$g" -eq 1 ]] ||  [[ "$h" -eq 1 ]] ||  [[ "$i" -eq 1 ]] ||  [[ "$j" -eq 1 ]];
 then
    printf "nastaveni se nezdarilo\n"

 else

        printf "DEBUG bezi!!!\n"
        fw ctl kdebug -T -f >> /var/log/securexl.ctl &
        fwaccel conns >> /var/log/sxl.txt
        fwaccel templates >> /var/log/E_templates.txt
        printf "kolektuji fwaccel conns a fwaccel templates do souboru!!!\n"
        printf "########################################\n"
        ps aux | egrep -i "fw ctl kde|fw monitor|tcpdump"
fi
}



main(){

nastav_kernel_secure_xl
nastav_tcpdump_a_monitor
nastav_debug_secure_xl


}

main