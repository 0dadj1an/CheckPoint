#!/bin/bash -f
#
#==============================================================================
#title	    :remover of old backups
#descrition :remove older backups from mgmt server since IPS moving backup to it
#author	    :ivo.hrbacek@ixperta.com
#version    :0.0002, for R77.30 platform
#usage	    :this script is executed on monthly basis via cron


#==============================================================================

# Use Check Point enviroment variables, see sk90441
source /opt/CPshrd-R80/tmp/.CPprofile.sh


BFOLDER=/var/log/CPbackup/backups
MDATE=`date -d "-31 days" "+%b_%Y"`


date

echo "########"
echo "LIST OF BACKUPS"
ls -la $BFOLDER

echo "########"
echo "Removing old backups...."
echo "########"
find $BFOLDER -name "*$MDATE*" | xargs rm -f

echo "LIST OF REMAINING BACKUPS"
ls -la $BFOLDER
