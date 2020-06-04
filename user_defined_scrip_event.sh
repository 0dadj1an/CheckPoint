#!/bin/bash
#ivohrbacek@gmail.com

THEEVENT=$(cat)

echo "Subject: Detect alert generated" >> /var/tmp/Event.txt
echo "" >> /var/tmp/Event.txt
echo "$THEEVENT" >> /var/tmp/Event.txt
echo "" >> /var/tmp/Event.txt

$FWDIR/bin/sendmail -s 'DETECT_ALERT' -t 80.65.176.170 -f  ivo.hrbacek@ixperta.com < /var/tmp/Event.txt

rm -r /var/tmp/Event.txt

exit 0
