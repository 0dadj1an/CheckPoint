#!/bin/sh
#sk113955
#this script will discard all WEB_API open worksessions without any changes.

# system domain
psql_client cpm postgres -c "select objid from worksession where state='OPEN' and numberoflocks=0 and numberofoperations=0 and applicationname='WEB_API';" > api_sessions.txt
#erase first two lines, objid: and ---------
sed -i '1d' api_sessions.txt
sed -i '1d' api_sessions.txt

#erase last two lines of \n
sed -i '$ d' api_sessions.txt
sed -i '$ d' api_sessions.txt

numberOfRecords="$(wc -l <api_sessions.txt)"

echo "Going to discard ${numberOfRecords} web_api worksessions."

mgmt_cli login -r true > id.txt;
for l in `cat api_sessions.txt`; do echo "About to discard worksession: ${l}"; mgmt_cli discard uid ${l} -s id.txt; done;
echo "About to discard my own WEB_API worksession:";
mgmt_cli discard -s id.txt;mgmt_cli logout -s id.txt

echo " "
echo "Finished."
echo "Note: List of WEB_API worksessions that were closed: api_sessions.txt"