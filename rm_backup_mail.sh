#!/bin/bash


BFOLDER=/root/fwmgmt_backups/
DDATE=`date -d "-1 days" "+%d_%b_%Y"`


find $BFOLDER -name "*$DDATE*" | xargs rm -f

MSG="Location:"
a=$(pwd)
MSG2="File:"
b=$(ls $BFOLDER|grep backup_fwm)


printf " $MSG $a\n $MSG2 $b\n " | mail -s MIT:list_of_nagios_backups -r nagois@moravia-it.com fw_admins@ixperta.com


