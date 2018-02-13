#!/bin/bash



installProductFile=/web/cgi-bin2/install_products.tcl
installProductFileTmp=install_product_tmp
importSummaryFile=/web/htdocs2/webui/ftw/ftw_import_summary.js
importSummaryFileTmp=ftw_import_summary_tmp

cp $installProductFile ${installProductFile}.backup
cp $importSummaryFile ${importSummaryFile}.backup
cp $installProductFile $installProductFileTmp
cp $importSummaryFile $importSummaryFileTmp

######requirement 5 - Must change it to fail open (under manage & settings > blades > APP&URL)#######
filePath=/web/htdocs2/webui/modifyFailOpen.sh

cat << EOF > $filePath
#!/bin/sh
psql_client cpm postgres -c "select d1.objid, d2.name from dleobjectderef_data d1, dleobjectderef_data d2 where 
d1.domainid=d2.objid and d1.dlesession=0 and not d1.deleted and d1.name='Application Control & URL Filtering Settings';" > tmp.txt
sed  '/SMC/!d' tmp.txt > tmp2.txt
ObjectName=\`sed '/SMC/!d' tmp.txt | awk -F'[|]' '{print \$(1)}'\`
mgmt_cli -r true set generic-object uid \$ObjectName gwFailure false
mgmt_cli -r true set generic-object uid \$ObjectName urlfSslCnEnabled true
EOF


deleteCmd="/bin/rm " 

#isDemoMode Section
runScript1='puts $pp "echo \\"'
runScript2='\\" >> \/etc\/rc.local"'
runScrip=$filePath 
InitdLocation='echo \\\"cpprod_util CPPROD_SetValue MGMTAPI OverrideAutoStart 1 0 1\\\"'
sed -i "/${InitdLocation}/i \
${runScript1}${filePath}${runScript2}" $installProductFileTmp
sed -i "/${InitdLocation}/i \
${runScript1}${deleteCmd}${filePath}${runScript2}" $installProductFileTmp

#isPostInstall Section
runScript1='puts $pp "'
runScript2='"'
runScrip=$filePath 
InitdLocation='puts $pp "cpprod_util CPPROD_SetValue MGMTAPI OverrideAutoStart 1 0 1"'
sed -i "/${InitdLocation}/i \
${runScript1}${filePath}${runScript2}" $installProductFileTmp
sed -i "/${InitdLocation}/i \
${runScript1}${deleteCmd}${filePath}${runScript2}" $installProductFileTmp


##########  requirement 5 - end   #########################################################################


######### requirement 6,7,8,9  ##############################
profile_conf_file_first=$FWDIR/conf/am_profiles.C
profile_conf_file_second=$FWDIR/conf/defaultDatabase/am_profiles.C
tmp_conf_file=/tmp/am_profile_tmp.C

cat $profile_conf_file_first > $tmp_conf_file

inspect_av_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 'av_settings' | grep -A0 'inspect_incoming_files_interfaces ' | cut -f1 -d: );
inspect_av_lnumber=`echo $inspect_av_lnumber | cut -c1-4`
inspect_te_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 'te_settings' | grep -A0 'inspect_incoming_files_interfaces ' | cut -f1 -d: );
inspect_te_lnumber=`echo $inspect_te_lnumber | cut -c1-4`
inspect_line="\t\t\t:inspect_incoming_files_interfaces (all)"
all_files_proactive_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 'av_settings' | grep -A0 'all_files_proactive_scan_enabled ' | cut -f1 -d: );
all_files_proactive_lnumber=`echo $all_files_proactive_lnumber | cut -c1-4`
all_files_proactive_line="\t\t\t:all_files_proactive_scan_enabled (true)"
file_type_process_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 'av_settings' | grep -A0 'file_type_process ' | cut -f1 -d: );
file_type_process_lnumber=`echo $file_type_process_lnumber | cut -c1-4`
file_type_process_line="\t\t\t:file_type_process (all_file_types)"

performance_impact_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A0 ':performance_impact ' | cut -f1 -d: );
performance_impact_lnumber=`echo $performance_impact_lnumber | cut -c1-4`
performance_impact_line="\t\t:performance_impact (high)"
performance_impact_high_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A0 ':performance_impact_high ' | cut -f1 -d: );
performance_impact_high_lnumber=`echo $performance_impact_high_lnumber | cut -c1-4`
performance_impact_high_line="\t\t:performance_impact_high (true)"

high_name_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 ':email_settings' | grep -A4 ':high_confidence' | grep -A0 'Name' | cut -f1 -d: );
high_name_lnumber=`echo $high_name_lnumber | cut -c1-4`
high_uid_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A50 ':email_settings' | grep -A4 ':high_confidence' | grep -A0 'Uid' | cut -f1 -d: );
high_uid_lnumber=`echo $high_uid_lnumber | cut -c1-4`

med_name_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A70 ':email_settings' | grep -A4 ':medium_confidence' | grep -A0 'Name' | cut -f1 -d: );
med_name_lnumber=`echo $med_name_lnumber | cut -c1-4`
med_uid_lnumber=$(grep -nA3000 'Optimized' $tmp_conf_file | grep -A70 ':email_settings' | grep -A4 ':medium_confidence' | grep -A0 'Uid' | cut -f1 -d: );
med_uid_lnumber=`echo $med_uid_lnumber | cut -c1-4`

detect_line="\t\t\t:Name (Detect)"
uid_line="\t\t\t:Uid (\"{5D5500C7-BDCB-42EB-BB49-AD4EE802F62C}\")"

sed -i "${inspect_av_lnumber}s/.*/$inspect_line/" $tmp_conf_file
sed -i "${inspect_te_lnumber}s/.*/$inspect_line/" $tmp_conf_file
sed -i "${all_files_proactive_lnumber}s/.*/$all_files_proactive_line/" $tmp_conf_file
sed -i "${file_type_process_lnumber}s/.*/$file_type_process_line/" $tmp_conf_file
sed -i "${performance_impact_lnumber}s/.*/$performance_impact_line/" $tmp_conf_file
sed -i "${performance_impact_high_lnumber}s/.*/$performance_impact_high_line/" $tmp_conf_file
sed -i "${high_name_lnumber}s/.*/$detect_line/" $tmp_conf_file
sed -i "${high_uid_lnumber}s/.*/$uid_line/" $tmp_conf_file
sed -i "${med_name_lnumber}s/.*/$detect_line/" $tmp_conf_file
sed -i "${med_uid_lnumber}s/.*/$uid_line/" $tmp_conf_file

cp $profile_conf_file_first ${profile_conf_file_first}.backup
cp $profile_conf_file_second ${profile_conf_file_second}.backup
cp $tmp_conf_file $profile_conf_file_first
cp $tmp_conf_file $profile_conf_file_second
rm $tmp_conf_file

##########################################################


######requirement 3,13  - remove child abuse rule + add new rule that will remove FW logs#################

	#isDemoMode Section
	origLine='Block Child Abuse sites\\\\\\" service \\\\\\"Child Abuse\\\\\\" action drop'
	newLine='for app url connections\\\\\\" destination Internet track.type \\\\\\"Detailed Log\\\\\\" track.accounting true action accept'
	nextLineStart='puts $pp "echo \\"'
	nextLine='mgmt_cli set access-rule layer Network name \\\\\\"for app url connections\\\\\\" track.per-connection false'
	nextLineEnd=' -s /tmp/sid >> /var/log/ftw_install.log 2>&1\\" >> /etc/rc.local"'
	origLine1='threat-emulation false anti-bot false anti-virus false'
	newLine1='threat-emulation true anti-bot true anti-virus true'
	#replace text
	sed -i "s/${origLine}/${newLine}/" $installProductFileTmp
	sed -i "/${newLine}/a ${nextLineStart}${nextLine}${nextLineEnd}" $installProductFileTmp
	sed -i '/ProtocolsLogging/d' $installProductFileTmp
	sed -i "s/${origLine1}/${newLine1}/" $installProductFileTmp
	
	#isPostInstall Section
	origLine='Block Child Abuse sites\\\" service \\\"Child Abuse\\\" action drop'
	newLine='for app url connections\\\" destination Internet track.type \\\"Detailed Log\\\" track.accounting true action accept'
	nextLineStart='puts $pp "'
	nextLine='mgmt_cli set access-rule layer Network name \\\"for app url connections\\\" track.per-connection false'
	nextLineEnd=' -s /tmp/sid >> /var/log/ftw_install.log 2>&1"'
	origLine1='threat-emulation false anti-bot false anti-virus false'
	newLine1='threat-emulation true anti-bot true anti-virus true'
	#replace text
	sed -i "s/${origLine}/${newLine}/" $installProductFileTmp
	sed -i "/${newLine}/a ${nextLineStart}${nextLine}${nextLineEnd}" $installProductFileTmp
	sed -i '/ProtocolsLogging/d' $installProductFileTmp
	sed -i "s/${origLine1}/${newLine1}/" $installProductFileTmp
######   requirement 3,13  - end ##############################################################################



###### kfirY additions ######
	#change track to track.type
	sed -i "s/AcceptAll action accept track none/AcceptAll action accept track.type none/" $installProductFileTmp
	mv $installProductFileTmp $installProductFile

	#install eventia
	sed -i 's/install_eventia: false/install_eventia: true/' $importSummaryFileTmp
	mv $importSummaryFileTmp $importSummaryFile
##### kfirY additions - end #####################

chmod -R 755 $filePath
chmod -R 755 $importSummaryFile
chmod -R 755 $installProductFile