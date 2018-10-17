#!/bin/bash

main_username="admin"
main_username_password="checkpoint123"

#login to system data domain
printf "*** Login to System Data domain to create admins ***\n\n"
mgmt_cli login user ${main_username} password ${main_username_password} domain "System Data" > id.txt
cat id.txt

#create admins (for cloud demo the admins below must be also configured in the cloud demo web service so they can be returned as built-in admins for usage in the login view)
printf "*** Create administrators ***\n\n"
mgmt_cli add-administrator name "Walter" password "demo123"  must-change-password false permissions-profile "Super User" -s id.txt
mgmt_cli add-administrator name "Saul" password "demo123"  must-change-password false permissions-profile "Super User" -s id.txt
mgmt_cli add-administrator name "Jesse" password "demo123"  must-change-password false permissions-profile "Super User" -s id.txt
mgmt_cli add-administrator name "Skyler" password "demo123"  must-change-password false permissions-profile "Super User" -s id.txt


#publish
printf "*** Publish administrators changes ****\n\n"
mgmt_cli set-session description "Add administrators and tags" new-name "Add built-in administrators and tags" -s id.txt
mgmt_cli publish -s id.txt


#logout from system data
printf "*** Logout from System Data ****\n\n"
mgmt_cli logout -s id.txt


#login
printf "\n\n*** Login ****\n\n"
mgmt_cli login user ${main_username} password ${main_username_password} > id.txt
cat id.txt

#create tags
printf "*** Create tags ***\n\n"
mgmt_cli add-tag name "Internal_gw" color red -s id.txt
mgmt_cli add-tag name "External_gw" color yellow -s id.txt
mgmt_cli add-tag name "DMZ_gw" color orange -s id.txt
mgmt_cli add-tag name "Europe_gw" color orchid -s id.txt
mgmt_cli add-tag name "ThreatEmulation_gw" color blue -s id.txt


#create gateways
printf "*** Create gateways ***\n\n"
mgmt_cli add-simple-gateway name "EuropeBranchGw" version "R80.10" comments "Europe Office gateway" ip-address 192.0.2.100 firewall true anti-bot true anti-virus true application-control true threat-emulation true url-filtering true ips true vpn true interfaces.1.name "eth0" interfaces.1.ip-address 192.0.2.100 interfaces.1.mask-length 24 interfaces.1.anti-spoofing true interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 203.0.113.1 interfaces.2.mask-length 25 interfaces.2.anti-spoofing true interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["Europe_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "HQgw" version "R80.10" comments "Main Office gateway" ip-address 192.0.2.200 firewall true anti-bot true anti-virus true application-control true threat-emulation true ips true url-filtering true vpn true interfaces.1.name "eth0" interfaces.1.ip-address 192.0.2.200 interfaces.1.mask-length 24 interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 198.51.100.59 interfaces.2.mask-length 25 interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" interfaces.3.name "eth2" interfaces.3.ip-address 198.51.100.129 interfaces.3.mask-length 25 interfaces.3.topology "INTERNAL" interfaces.3.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["Internal_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "Corporate-GW" version "R80.10" comments "First Office gateway" ip-address 198.51.100.5 firewall true application-control true anti-bot true anti-virus true vpn true url-filtering true data-awareness true ips true threat-emulation true interfaces.1.name "eth0" interfaces.1.ipv4-address "198.51.100.5" interfaces.1.ipv4-network-mask "255.255.255.0" interfaces.1.anti-spoofing true interfaces.1.topology "EXTERNAL" interfaces.1.security-zone true interfaces.1.security-zone-settings.auto-calculated true interfaces.2.name "eth1" interfaces.2.ipv4-address "22.20.105.5" interfaces.2.ipv4-network-mask "255.255.255.0" interfaces.2.anti-spoofing true interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" interfaces.2.security-zone true interfaces.2.security-zone-settings.auto-calculated true interfaces.3.name "eth2" interfaces.3.ipv4-address "151.20.4.5" interfaces.3.ipv4-network-mask "255.255.255.0" interfaces.3.anti-spoofing true interfaces.3.topology "INTERNAL" interfaces.3.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" interfaces.3.security-zone true interfaces.3.security-zone-settings.specific-zone "DMZZone" interfaces.4.name "eth3" interfaces.4.ipv4-address "183.82.0.5" interfaces.4.ipv4-network-mask "255.255.255.0" interfaces.4.anti-spoofing true interfaces.4.topology "INTERNAL" interfaces.4.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["Internal_gw"]' interfaces.4.security-zone true interfaces.4.security-zone-settings.specific-zone "DMZZone" -s id.txt
mgmt_cli add-simple-gateway name "BranchOffice" version "R77.30" comments "Second office gateway" ip-address 198.51.100.7 firewall true application-control true vpn true url-filtering true interfaces.1.name "eth0" interfaces.1.ipv4-address "198.51.100.7" interfaces.1.ipv4-network-mask "255.255.255.0" interfaces.1.anti-spoofing true interfaces.1.topology "EXTERNAL" interfaces.1.security-zone true interfaces.1.security-zone-settings.auto-calculated true interfaces.2.name "eth1" interfaces.2.ipv4-address "145.80.110.7" interfaces.2.ipv4-network-mask "255.255.255.0" interfaces.2.anti-spoofing true interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["External_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "RemoteBranchGw" version "R80.10" comments "RemoteBranchGw" ip-address 198.51.100.120 firewall true ips true interfaces.1.name "eth0" interfaces.1.ip-address 98.51.100.120 interfaces.1.mask-length 24 interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 172.0.113.112 interfaces.2.mask-length 25 interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["External_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "ThreatEmulationDevice" version "R80.10" comments "Threat Emulation" ip-address 192.0.111.13 firewall true threat-emulation true interfaces.1.name "eth0" interfaces.1.ip-address 192.0.111.13 interfaces.1.mask-length 24 interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 172.0.1.113 interfaces.2.mask-length 25 interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["ThreatEmulation_gw", "External_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "Remote-1-gw" version "R80.10" comments "Remote-1-gw" ip-address 192.0.22.1 firewall true anti-bot true anti-virus true application-control true threat-emulation true url-filtering true ips true vpn true interfaces.1.name "eth0" interfaces.1.ip-address 192.0.22.1 interfaces.1.mask-length 24 interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 172.0.113.1 interfaces.2.mask-length 25 interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["External_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "Remote-2-gw" version "R80.10" os-name "SecurePlatform" comments "Remote-2-gw" ip-address 192.0.23.1 firewall true anti-bot true anti-virus true application-control true threat-emulation true url-filtering true ips true vpn true interfaces.1.name "eth0" interfaces.1.ip-address 192.0.3.1 interfaces.1.mask-length 24 interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 172.0.113.1 interfaces.2.mask-length 25 interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["External_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "Remote-3-gw" version "R80.10" comments "Remote-3-gw" ip-address 192.0.24.1 firewall true anti-bot true anti-virus true application-control true threat-emulation true url-filtering true ips true vpn true interfaces.1.name "eth0" interfaces.1.ip-address 192.0.4.1 interfaces.1.mask-length 24 interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 172.0.1.1 interfaces.2.mask-length 25 interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["External_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "Remote-4-gw" version "R80.10" comments "Remote-4-gw" ip-address 192.0.25.1 firewall true anti-bot true anti-virus true application-control true threat-emulation true url-filtering true ips true vpn true interfaces.1.name "eth0" interfaces.1.ip-address 192.0.5.1 interfaces.1.mask-length 24 interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 172.0.2.1 interfaces.2.mask-length 25 interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["External_gw"]' -s id.txt
mgmt_cli add-simple-gateway name "Remote-5-gw" version "R80.10" comments "Remote-5-gw" ip-address 192.0.26.1 firewall true anti-bot true anti-virus true application-control true threat-emulation true url-filtering true ips true vpn true interfaces.1.name "eth0" interfaces.1.ip-address 192.0.6.1 interfaces.1.mask-length 24 interfaces.1.topology "EXTERNAL" interfaces.2.name "eth1" interfaces.2.ip-address 172.0.3.1 interfaces.2.mask-length 25 interfaces.2.topology "INTERNAL" interfaces.2.topology-settings.ip-address-behind-this-interface "LOCAL_NETWORK" tags '["External_gw"]' -s id.txt

#publish
printf "*** Publish created gateways ****\n\n"
mgmt_cli set-session description "Create Gateways" new-name "Create Gateways" -s id.txt
mgmt_cli publish -s id.txt



#create security zones
printf "*** Create security zones ***\n\n"
mgmt_cli add-security-zone name "Finance" -s id.txt


#Create hosts
printf "*** Create hosts ***\n\n"
mgmt_cli add-host name "DNS Server" ip-address 10.0.0.138 -s id.txt
mgmt_cli add-host name "ERP Server" ip-address 10.0.0.60 -s id.txt
mgmt_cli add-host name "Exchange" ip-address 198.51.100.11 -s id.txt
mgmt_cli add-host name "FTP_Int" ip-address 10.0.0.97 -s id.txt
mgmt_cli add-host name "Web Server" ip-address 151.20.4.13 -s id.txt
mgmt_cli add-host name "Public FTP Server" ip-address 151.20.4.15 -s id.txt
mgmt_cli add-host name "Mail Relay" ip-address 151.20.4.16 -s id.txt
mgmt_cli add-host name "Proxy Server" ip-address 151.20.4.142 -s id.txt
mgmt_cli add-host name "Internal Lab srv 05" ip-address 10.25.2.75 -s id.txt


#Create networks
printf "*** Create networks ***\n\n"
mgmt_cli add-network name "HR LAN" subnet 198.51.100.15 subnet-mask 255.255.255.255 -s id.txt
mgmt_cli add-network name "HQ LAN" subnet 22.20.105.0 subnet-mask 255.255.255.0 -s id.txt
mgmt_cli add-network name "Sales LAN" subnet 198.51.100.16 subnet-mask 255.255.255.255 -s id.txt
mgmt_cli add-network name "Branch Office LAN" subnet 145.80.110.0 subnet-mask 255.255.255.0 -s id.txt
mgmt_cli add-network name "Data Center LAN" subnet 10.0.0.0 subnet-mask 255.255.255.0 -s id.txt
mgmt_cli add-network name "Internal Lab Net" subnet 10.25.80.0 subnet-mask 255.255.255.0 -s id.txt
mgmt_cli add-network name "Wireless Guests Network" subnet 183.82.0.0 subnet-mask 255.255.0.0 -s id.txt


#Create services
printf "*** Create services ***\n\n"
mgmt_cli add-service-tcp name "Http_9090" port 9090 -s id.txt


#Create time objects
printf "*** Create time ***\n\n"
mgmt_cli add-time name "Temp Access" start.date "26-Mar-2017" start.time "10:00" start-now "false" end.date "26-Mar-2017" end.time "12:00" end-never "false" recurrence.pattern "Daily" -s id.txt


#Create Network group
printf "*** Create time group ***\n\n"
mgmt_cli add-group name "Corporate LANs" members '["HQ LAN", "HR LAN", "Sales LAN"]' -s id.txt


#Create application/site
printf "*** Create application/site ***\n\n"
mgmt_cli add-application-site name "Blocked URLs" primary-category "Custom_Application_Site" url-list.1 "www.block*.*" urls-defined-as-regular-expression true -s id.txt
mgmt_cli add-application-site name "Report Portal" primary-category "Custom_Application_Site" url-list.1 "*.portal" urls-defined-as-regular-expression false -s id.txt
mgmt_cli add-application-site name "Customer Service Portal" primary-category "Custom_Application_Site" url-list.1 "support.my-org.com" urls-defined-as-regular-expression false -s id.txt
mgmt_cli add-application-site name "mycompany.com" primary-category "Custom_Application_Site" url-list.1 "www.mycompany.com" urls-defined-as-regular-expression false -s id.txt


#Create communities
printf "*** Create communities ***\n\n"
mgmt_cli add-vpn-community-meshed name "Site2Site" gateways '["BranchOffice", "HQgw"]' -s id.txt


#Application Groups
printf "*** Create application group ***\n\n"
mgmt_cli add-application-site-group name "Inappropriate Sites" members.1 "Child Abuse" members.2 "High Risk" members.3 "Spyware / Malicious Sites" members.4 "Gambling" -s id.txt


#Create Service Group
printf "*** Create service group ***\n\n"
mgmt_cli add-service-group name "Manage Services" members.1 "GoToMyPC" members.2 "ssh" members.3 "https" -s id.txt
mgmt_cli add-service-group name "Internet Services" members.1 "HTTPS_proxy" members.2 "HTTP_proxy" members.3 "IMAP-SSL" members.4 "POP3S" members.5 "http" members.6 "https" -s id.txt


#############



#Create users and user groups
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name Clientless-vpn-user comments "Clientless VPN Users with Certificates" userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name Mobile-vpn-user userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name HR_Partners userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name Administrators comments "Security Admins" userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name Finance_Users comments "Finance_Users" userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name John_Adams userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name L2TP-vpn-user comments "L2TP VPN Users - Partners accessing our web server" userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name Partners userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name Helpdesk userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name Customers userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt
mgmt_cli add-generic-object create "com.checkpoint.objects.classes.dummy.CpmiUser" name URL-bypass-group userc.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUserc" userc.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiSpecificUsercIke" -s id.txt



Create access roles
printf "*** Create access roles ***\n\n"
mgmt_cli add-access-role name "Admins" networks "any" users "any" machines "all identified" remote-access-clients "any" -s id.txt
mgmt_cli add-access-role name "Finance User" networks "any" users "any" machines "all identified" remote-access-clients "any" -s id.txt
mgmt_cli add-access-role name "HR" networks "any" users "any" machines "all identified" remote-access-clients "any" -s id.txt
mgmt_cli add-access-role name "IT Department" networks "any" users "any" machines "all identified" remote-access-clients "any" -s id.txt
mgmt_cli add-access-role name "Sales" nnetworks "any" users "any" machines "all identified" remote-access-clients "any" -s id.txt
mgmt_cli add-access-role name "Remote Access Users" networks "any" users "any" machines "all identified" remote-access-clients "any" -s id.txt
mgmt_cli add-access-role name "IT Helpdesk Users" networks "any" users "any" machines "all identified" remote-access-clients "any" -s id.txt
mgmt_cli add-access-role name "Guests" networks "any" users "any" machines "all identified" remote-access-clients "any" -s id.txt
mgmt_cli add access-role name "New Access Role 1" networks "any" users "any" machines "all identified" remote-access-clients "any"-s id.txt

#publish
printf "*** Publish new objects ****\n\n"
mgmt_cli set-session description "Add Objects" new-name "Add Objects" -s id.txt
mgmt_cli publish -s id.txt


#Create Layers
printf "*** Create Layers ***\n\n"
mgmt_cli add-access-layer name "Web Control Layer" applications-and-url-filtering true data-awareness true shared true -s id.txt
mgmt_cli add-access-layer name "Data Center Layer" applications-and-url-filtering true data-awareness true -s id.txt
mgmt_cli add-access-layer name "Guest Exception Layer" applications-and-url-filtering true data-awareness true -s id.txt
mgmt_cli add-access-layer name "Public FTP Layer" data-awareness true -s id.txt
mgmt_cli add-access-layer name "RDP Exceptions Layer" -s id.txt
mgmt_cli add-access-layer name "Customer Service Server Layer" applications-and-url-filtering true -s id.txt

#Turn on applications and url filtering on Corporate_Policy Network layer
mgmt_cli add-access-layer name "Corporate_Policy Network" applications-and-url-filtering true -s id.txt


#Add Rules to "Web Control Layer"
printf "*** Add rules to 'Web Control Layer' ***\n\n"
mgmt_cli add-access-rule layer "Web Control Layer" name "Block specific categories for all employees" action drop position top destination '["Internet"]' service.1 "Social Networking" service.2 "Streaming Media Protocols" service.3 "P2P File Sharing" user-check.interaction "Blocked Message - Access Control" track.type log track.accounting false -s id.txt
mgmt_cli set-access-rule layer "Web Control Layer" name "Block specific categories for all employees" track.accounting false -s id.txt
mgmt_cli add-access-rule layer "Web Control Layer" name "Block specific URLs" action drop position top destination '["Internet"]' service.1 "Blocked URLs" track.type log track.accounting false -s id.txt
mgmt_cli set-access-rule layer "Web Control Layer" name "Block specific URLs" track.accounting false -s id.txt
mgmt_cli add-access-rule layer "Web Control Layer" name "All employees can access YouTube and Vimeo for work purposes" action ask position top destination '["Internet"]' service.1 "YouTube" service.2 "Vimeo" user-check.interaction "Company Policy" track.type log track.accounting false -s id.txt
mgmt_cli set-access-rule layer "Web Control Layer" name "All employees can access YouTube and Vimeo for work purposes" track.accounting false -s id.txt
mgmt_cli add-access-rule layer "Web Control Layer" name "HR can access to social network applications" action inform position top source '["HR"]' destination '["Internet"]' service.1 "Facebook" service.2 "Twitter" service.3 "LinkedIn" user-check.interaction "Access Approval" track.type log track.accounting false -s id.txt
mgmt_cli set-access-rule layer "Web Control Layer" name "HR can access to social network applications" track.accounting false -s id.txt
mgmt_cli add-access-rule layer "Web Control Layer" name "Ask user upon possible personal data exposure" action inform position top destination '["Internet"]' service.1 "http" content '["PCI - Credit Card Numbers", "U.S. Social Security Numbers - According to SSA"]' content-direction "up" user-check.interaction "Access Notification" user-check.frequency "once a day" user-check.confirm "per application/site" track.type log install-on "Corporate-GW" -s id.txt
mgmt_cli add-access-rule layer "Web Control Layer" name "Block download of executables from untrusted sites" action drop position top destination '["Internet"]' service.1 "Uncategorized" content "Executable File" content-direction "down" user-check.interaction "Blocked Message - Access Control" track.type log track.accounting true install-on "Corporate-GW" -s id.txt
mgmt_cli add-access-rule layer "Web Control Layer" name "Block abuse / high risk applications" action drop position top destination '["Internet"]' service.1 "Inappropriate Sites" user-check.interaction "Blocked Message - Access Control" track.type log track.accounting false -s id.txt
mgmt_cli set-access-rule layer "Web Control Layer" name "Block abuse / high risk applications" track.accounting false -s id.txt
#modify the automatic cleanup rule created when the layer was created. 
mgmt_cli set-access-rule layer "Web Control Layer" name "Cleanup rule" new-name "Cleanup" action accept track.type "Detailed Log" track.accounting true -s id.txt


#Add Rules to "Data Center Layer"
printf "*** Add rules to 'Data Center Layer' ***\n\n"
mgmt_cli add-access-rule layer "Data Center Layer" name "Customer Service Server" action accept position top service.1 "Customer Service Portal" track.type log track.accounting true -s id.txt 
mgmt_cli add-access-rule layer "Data Center Layer" name "Internal DNS Access" action accept position top source '["DMZZone","InternalZone"]' destination '["DNS Server"]' service.1 "dns" track.type log -s id.txt
mgmt_cli add-access-rule layer "Data Center Layer" name "Only Finance department has access to reports" action accept position top source '["Finance User"]' destination '["ERP Server"]' service.1 "Report Portal" track.type "Extended log" track.accounting false -s id.txt
mgmt_cli set-access-rule layer "Data Center Layer" name "Only Finance department has access to reports" track.accounting false -s id.txt
mgmt_cli add-access-rule layer "Data Center Layer" name "Mobile Access for Internal FS" action accept position top source '["Sales"]' destination '["FTP_Int"]' vpn "RemoteAccess" service.1 "ftp" data '["Document File","Archive File"]' track.type "Extended Log" track.accounting false -s id.txt
mgmt_cli set-access-rule layer "Data Center Layer" name "Mobile Access for Internal FS" track.accounting false -s id.txt
#modify the automatic cleanup rule created when the layer was created. 
mgmt_cli set-access-rule layer "Data Center Layer" name "Cleanup rule" new-name "Cleanup" track.type log -s id.txt


#Add Rules to "Guest Exception Layer" Layer
printf "*** Add rules to 'Guest Exception Layer' ***\n\n"
mgmt_cli add-access-rule layer "Guest Exception Layer" name "Internal lab temporary access for board demo (Sunday, Mar 26th 10:00-12:00)" service.1 "https" action accept position top destination '["Internal Lab srv 05"]' track.type log time "Temp Access" -s id.txt
mgmt_cli add-access-rule layer "Guest Exception Layer" name "Guests outgoing traffic" action accept position top destination '["ExternalZone"]' track.type "Extended Log" -s id.txt
mgmt_cli add-access-rule layer "Guest Exception Layer" name "Guests web access through Portal" action accept position top source '["Guests"]' destination '["Internet"]' service.1 "Web" service.2 "Web_Proxy" track.type "Extended Log" action-settings.enable-identity-captive-portal true -s id.txt
#modify the automatic cleanup rule created when the layer was created. 
mgmt_cli set-access-rule layer "Guest Exception Layer" name "Cleanup rule" new-name "Cleanup" track.type log -s id.txt


#Add Rules to "Public FTP Layer" Layer
printf "*** Add rules to 'Public FTP Layer' ***\n\n"
mgmt_cli add-access-rule layer "Public FTP Layer" name "External users limited for upload only" action drop position top source '["ExternalZone"]' content "Any File" content-direction "down" track.type log -s id.txt
#modify the automatic cleanup rule created when the layer was created. 
mgmt_cli set-access-rule layer "Public FTP Layer" name "Cleanup rule" new-name "Allow public FTP access" action Accept track.type "Extended Log" track.accounting false -s id.txt
mgmt_cli set-access-rule layer "Public FTP Layer" name "Allow public FTP access" track.accounting false -s id.txt


#Add Rules to "RDP Exceptions Layer"
printf "*** Add rules to 'RDP Exceptions Layer' ***\n\n"
mgmt_cli add-access-rule layer "RDP Exceptions Layer" name "Allow RDP for internal lab" action Accept position top destination '["Internal Lab Net"]' track.type log -s id.txt
mgmt_cli add-access-rule layer "RDP Exceptions Layer" name "Allow RDP for Helpdesk" action Accept position top source '["IT Helpdesk Users"]' track.type log -s id.txt
mgmt_cli add-access-rule layer "RDP Exceptions Layer" name "Alert on remote RDP attempts" action Drop position top source '["ExternalZone"]' track.type log track.alert alert -s id.txt
#modify the automatic cleanup rule created when the layer was created. 
mgmt_cli set-access-rule layer "RDP Exceptions Layer" name "Cleanup rule" new-name "Cleanup" action Drop track.type log -s id.txt


#Add Rules to "Customer Service Server Layer"
printf "*** Add rules to 'Customer Service Server Layer' ***\n\n"
mgmt_cli add-access-rule layer "Customer Service Server Layer" name "Allow access to the company's public web site" action accept position top service.1 "mycompany.com" track.type log -s id.txt
#modify the automatic cleanup rule created when the layer was created. 
mgmt_cli set-access-rule layer "Customer Service Server Layer" name "Cleanup rule" new-name "Cleanup" action Drop track.type log -s id.txt


#section Cleanup
mgmt_cli add-access-section name "Cleanup" position.top "Corporate_Policy Network" layer "Corporate_Policy Network" -s id.txt
#modify the automatic cleanup rule created when the layer was created. 
mgmt_cli set-access-rule layer "Corporate_Policy Network" name "Cleanup rule" new-name "Cleanup" action Drop track.type log -s id.txt


mgmt_cli add-access-section name "Child Abuse & Phishing" position.top "Corporate_Policy Network" layer "Corporate_Policy Network" -s id.txt
#Add "Child Abuse" rule and "phishing" rule - needed to create a security alert in the compliance blade - URL130 URL131 Best practices
mgmt_cli add-access-rule layer "Corporate_Policy Network" position.top "Child Abuse & Phishing" name "Child Abuse - this rule is used to create a security alert in the compliance blade, URL130 best practice" service.1 "Child Abuse" action Drop track.type log -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" position.top "Child Abuse & Phishing" name "Phishing - this rule is used to create a security alert in the compliance blade, URL131 best practice" service.1 "Phishing" action Drop track.type log -s id.txt


#section "Temporary Access Grant"
mgmt_cli add-access-section name "Temporary Access Grant" position.top "Corporate_Policy Network" layer "Corporate_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" position.top "Temporary Access Grant" name "Wireless Guests access" action "Apply Layer" inline-layer "Guest Exception Layer" source '["Wireless Guests Network"]' -s id.txt


#section "Data Center Access" - TP blade
mgmt_cli set-threat-rule rule-number 1 layer "Corporate_Policy Threat Prevention" new-name "Recommended Protections" -s id.txt
mgmt_cli add-threat-rule layer "Corporate_Policy Threat Prevention" position "top" name "Data Center Protection" comments "" protected-scope "Data Center LAN" action "Strict" install-on "Policy Targets" -s id.txt


#section "Data Center Access"
mgmt_cli add-access-section name "Data Center Access" position.top "Corporate_Policy Network" layer "Corporate_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" position.top "Data Center Access" name "Policy for access to Data Center servers" action "Apply Layer" inline-layer "Data Center Layer" destination '["Data Center LAN"]' -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" position.top "Data Center Access" name "RDP Exceptions" action "Apply Layer" inline-layer "RDP Exceptions Layer" service.1 "Remote_Desktop_Protocol" service.2 "Remote_Desktop_Protocol_UDP" -s id.txt


#section "DMZ"
mgmt_cli add-access-section name "DMZ" position.top "Corporate_Policy Network" layer "Corporate_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" name "Access to company's web server" position.top "DMZ" action "Apply Layer" inline-layer "Customer Service Server Layer" source '["ExternalZone"]' destination '["Web Server"]' service.1 "https" -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" name "Allow corporate LANs to DMZ" action accept position.bottom "DMZ" source '["Corporate LANs"]' destination '["DMZZone"]' service.1 "https" service.2 "http" service.3 "ftp" service.4 "smtp" track.type log -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" name "Public FTP Access" position.bottom "DMZ" action "Apply Layer" inline-layer "Public FTP Layer" destination '["Public FTP Server"]' -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" name "Proxy Web access" action accept position.bottom "DMZ" source '["Proxy Server"]' service.1 "Web" track.type log -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" name "External mail traffic" action accept position.bottom "DMZ" source '["Mail Relay"]' service.1 "smtp" service.2 "SMTPS" track.type log -s id.txt


#section 'Access To Internet'
mgmt_cli add-access-section name "Access To Internet" position.top "Corporate_Policy Network" layer "Corporate_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" position.top "Access To Internet" name "DNS outgoing access" action accept source '["DNS Server"]' destination '["ExternalZone"]' service.1 "domain-udp" service.2 "domain-tcp" track.type log -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" position.top "Access To Internet" name "Access to Internet according to Web control policy" action "Apply Layer" inline-layer "Web Control Layer" source '["InternalZone"]' destination '["ExternalZone", "Proxy Server"]' service.1 "Web" service.2 "Web_Proxy" -s id.txt


#section 'VPN'
mgmt_cli add-access-section name "VPN" position.top "Corporate_Policy Network" layer "Corporate_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" name "VPN between Internal LANs and Branch office LAN" action accept position.bottom "VPN" source '["Corporate LANs","Branch Office LAN"]' destination '["Branch Office LAN","Corporate LANs"]' vpn "Site2Site" -s id.txt


#section 'Security Gateways Access'
mgmt_cli add-access-section name "Security Gateways Access" position.top "Corporate_Policy Network" layer "Corporate_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" name "Administrator Access to Gateways" action accept position.top "Security Gateways Access" source '["Admins"]' destination '["Corporate-GW"]' service.1 "Manage Services" -s id.txt
mgmt_cli add-access-rule layer "Corporate_Policy Network" name "Stealth rule" action drop position.bottom "Security Gateways Access" destination '["Corporate-GW"]' -s id.txt


#change package names
printf "*** Change policy package names and install targets ***\n\n"
mgmt_cli set-package name "Standard" new-name "Corporate_Policy" -s id.txt
mgmt_cli set-package name "Corporate_Policy" installation-targets "Corporate-GW" -s id.txt


#publish
printf "*** Publish corporate policy changes ****\n\n"
mgmt_cli set-session description "Add Corporate_Policy" new-name "Add Policy Package" -s id.txt
mgmt_cli publish -s id.txt


#Create Branch_Office_Policy policy Package
printf "*** Create Branch_Office_Policy policy package ***\n\n"
mgmt_cli add-package name "Branch_Office_Policy" access true threat-prevention true installation-targets "BranchOffice"  -s id.txt
mgmt_cli set-package name "Branch_Office_Policy" access-layers.add.1.name "Web Control Layer" access-layers.add.1.position 2 -s id.txt


#Add rules to Branch_Office_Policy Network Layer
printf "*** Add rules to 'Branch_Office_Policy Network' layer ***\n\n"

#section Clean Up
mgmt_cli add-access-section name "Cleanup" position.top "Branch_Office_Policy Network" layer "Branch_Office_Policy Network" -s id.txt
#modify the automatic cleanup rule created when the layer was created. 
mgmt_cli set-access-rule layer "Branch_Office_Policy Network" name "Cleanup rule" new-name "Cleanup" action Drop track.type log -s id.txt


#section Internet Access
mgmt_cli add-access-section name "Internet Access" position.top "Branch_Office_Policy Network" layer "Branch_Office_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Branch_Office_Policy Network" name "Access to Internet according to Web control policy (next layer)" action accept position.top "Internet Access" source '["Branch Office LAN"]' service.1 "Internet Services" track.type log -s id.txt


#section VPN
mgmt_cli add-access-section name "VPN" position.top "Branch_Office_Policy Network" layer "Branch_Office_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Branch_Office_Policy Network" name "VPN between Internal LANs and Branch office LAN" action accept position.top "VPN" source '["Corporate LANs","Branch Office LAN"]' destination '["Branch Office LAN","Corporate LANs"]' vpn "Site2Site" track.type log -s id.txt
mgmt_cli add-access-rule layer "Branch_Office_Policy Network" name "Branch office should have VPN access to servers (ERP on ftp_21)" action accept position.bottom "VPN" source '["Branch Office LAN"]' destination '["ERP Server","FTP_Int"]' service.1 "ftp" service.2 "ftp" vpn "Site2Site" track.type log -s id.txt
mgmt_cli add-access-rule layer "Branch_Office_Policy Network" name "Branch office should have VPN access to servers" action accept position.bottom "VPN" source '["Branch Office LAN"]' destination '["Exchange","DNS Server"]' vpn "Site2Site" service.1 "http" service.2 "https" service.3 "dns" service.4 "smtp" track.type log -s id.txt


#section GW access
mgmt_cli add-access-section name "GW Access" position.top "Branch_Office_Policy Network" layer "Branch_Office_Policy Network" -s id.txt
mgmt_cli add-access-rule layer "Branch_Office_Policy Network" name "Administrator Access to Gateways" action accept position.top "GW Access" source '["Admins"]' destination '["BranchOffice"]' service.1 "Manage Services" track.type log -s id.txt
mgmt_cli add-access-rule layer "Branch_Office_Policy Network" name "DHCP Server for the branch Office" action accept position.bottom "GW Access" destination '["BranchOffice"]' service.1 "dhcp-request" track.type log -s id.txt
mgmt_cli add-access-rule layer "Branch_Office_Policy Network" name "Stealth rule" action drop position.bottom "GW Access" destination '["BranchOffice"]' track.type log -s id.txt


#publish
printf "*** Publish branch office policy changes ****\n\n"
mgmt_cli set-session description "Add Branch_Office_Policy" new-name "Add Policy Package" -s id.txt
mgmt_cli publish -s id.txt


#logout
printf "*** Logout ****\n\n"
mgmt_cli logout -s id.txt


#create rules history
printf "*** Create rules history ***\n\n"

#login
printf "*** Login with different admin ****\n\n"
mgmt_cli login user "Saul" password "demo123" > id.txt
cat id.txt

#do some changes
mgmt_cli set-access-rule layer "Corporate_Policy Network" name "Administrator Access to Gateways" track.type log -s id.txt
mgmt_cli set-access-rule layer "Corporate_Policy Network" name "Stealth rule" track.type log -s id.txt
mgmt_cli set-access-rule layer "Corporate_Policy Network" name "VPN between Internal LANs and Branch office LAN" track.type log -s id.txt

#publish
printf "*** Publish ****\n\n"
mgmt_cli set-session description "Set rules in Corporate_Policy" new-name "Change Rules Tracking to Log" -s id.txt
mgmt_cli publish -s id.txt


#logout
printf "*** Logout ****\n\n"
mgmt_cli logout -s id.txt

