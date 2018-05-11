#!/bin/bash -f
#
#==============================================================================
#title      :ftp del script
#descrition :This script removes old bakups from ftp servers
#author     :ivo.hrbacek@ixperta.com a laura
#version    :0.0001
#==============================================================================
# CP enviroment variables for cron see sk77300, sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh


MDATE=`date -d "-31 days" "+%b_%Y"`
HOST='172.16.1.231'
USER='chpbck'
PASSWD=$(/usr/bin/base64 -i -d /home/ixp_hrbacek/enc)

printf "$MDATE"

/usr/bin/ftp -n  $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
dir
prompt
mdelete *$MDATE*.tgz
dir
quit
END_SCRIPT
exit 0



