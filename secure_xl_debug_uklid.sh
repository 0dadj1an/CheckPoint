#!/bin/bash
#ivohrbacek@gmail.com


DIRECTORY=/home/admin/debug
DATE=`date --rfc-3339=date`
#TIME=`date +"%T"`



nastav_kernel_secure_xl_default(){

echo "NASTAVUJI KERNEL PARAMETRY DO DEFAULTU"

fw ctl set int fwha_print_all_drops 0
a=$?
fw ctl set int fwha_dprint_io 0
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

uklid(){

echo "ZABIJIM TCPDUMP"
killall tcpdump
a=$?


echo "ZABIJIM DEBUG"
fw ctl debug 0
b=$?
sleep 1

echo "RESETUJI DEBUG FLAGS"
fwaccel dbg resetall
c=$?

sim dbg resetall
d=$?


if [[ "$a" -eq 1  ]] || [[ "$b" -eq 1 ]] || [[ "$c" -eq 1  ]] || [[ "$d" -eq 1 ]] ;
 then
    printf "uklid se z nejakeho duvodu nezdaril!!!\n"
    echo "tcpdump navratovka:" echo $a
    echo "debug navratovka": echo $b
    echo "debug parametry navratovka:" echo $c  echo $d
    printf "\n"
    printf "#########################################\n"
 else
    printf "uklizeno do defaultu\n"
    printf "######################\n"
    sleep 3
    ps aux | grep "fw ctl kde"
fi
}

archivuj(){

echo "ZACINAM ARCHIVACI"

if [ ! -d "$DIRECTORY" ]; then
  mkdir /home/admin/debug
fi

if [ -d "$DIRECTORY" ]; then
rm -r /home/admin/debug
mkdir /home/admin/debug
cd /home/admin/debug
tar -czf debug_akcenta_$DATE.tgz /var/log/destination.pcap /var/log/client.pcap /var/log/securexl.ctl /var/log/sxl.txt /var/log/templates.txt /var/log/fw_mon.cap
a=$?

if [[ "$a" -eq 1  ]];
 then
    printf "archivace se nezdarila!!!\n"

 else
    printf "archivace se zdarila, vystup v :$DIRECTORY\n"

    printf "#########################\n"
fi

fi




}

main(){
uklid
nastav_kernel_secure_xl_default
archivuj
}

main
