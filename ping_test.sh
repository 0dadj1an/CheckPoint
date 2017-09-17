#!/bin/bash

while true;


# monitored host 
host=checkpoint.com
# ISP dgw  
gw=95.143.243.129
# ice
ice=seznam.cz
#internet target
gw2=seznam.cz



do
        # check if there are no blank lines
        if [ ! -z $host ]; then
                #PINGCOUNT=5
                #PING=$(ping -c $PINGCOUNT $host | grep received | cut -d ',' -f2 | cut -d ' ' -f2) -- integer with if there are no responces 
                
packet_loss=$(ping -c 10 $host | grep -oP '\d+(?=% packet loss)')
                
                if [ $packet_loss -gt 0 ]; then

                        
                        echo "------------------------------------" >> /var/log/ping.log
                        date >> /var/log/ping.log
                        echo "CONNECTION_TO_MONITORED_HOST: $host IS_BAD, PACKET_LOSS_IS: $packet_loss %" >> /var/log/ping.log
					


                                                if [ ! -z $gw ]; then
               					
                				#PING=$(ping -c 10 $gw | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                                               
                				
							#if [ $PING -eq 0 ]; then
                        
                        					       # echo "NO_CONNECTION_TO_CSS_ISP_DGW!!: $gw" >> /var/log/ping.log
                                                
                        					
                                                              #else
									packet_loss=$(ping -c 10 $gw | grep -oP '\d+(?=% packet loss)')
                                                                        # this is how much it is sucessfull --> summary=$[100 - $packet_loss]

                                                                      
			                                               echo "CSS_ISP_DGW: $gw IS_RESPONDING_AND_PACKET_LOSS_IS  : $packet_loss %" >> /var/log/ping.log
                                                                       
                                                                       

                                                
                              
                                                       #fi
                                             fi

			

                                                if [ ! -z $gw2 ]; then
               					
                				PING=$(ping -c 10 $gw2 | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                                                
                				
							if [ $PING -eq 0 ]; then
                        
                        					        echo "NO_CONNECTION_TO_INTERNET!!: $gw2" >> /var/log/ping.log
						
								        

                                                
                        					
                                                              else
                                                                        packet_loss=$(ping -c 10 $gw2 | grep -oP '\d+(?=% packet loss)')
                                                                        # this is how much it is sucessfull --> summary=$[100 - $packet_loss]

			                                              echo "INTERNET_TARGET: $gw2 IS_RESPONDING_AND_PACKET_LOSS_IS : $packet_loss %" >> /var/log/ping.log
                                                                       
                                                                       

                                                
                              
                                                       fi
                                             fi  


                                          if [ ! -z $ice ]; then
                                          PINGCOUNT=4
                                          PING=$(ping -c $PINGCOUNT $ice | grep received | cut -d ',' -f2 | cut -d ' ' -f2)
                                           if [ $PING -eq 0 ]; then
                        
                                             
                                              echo "NO_CONNECTION_TO_ICE: $ice" >> /var/log/ping.log
						  
                                           else            
						netcat -z ${ice} 80
                                                           if [ $? -eq 0 ]; then
                                                              
                                                                 echo "SERVICE_ON_ICE_RUNNING" >> /var/log/ping.log

								echo "------------------------------------" >> /var/log/ping.log

                                                              else
                                                                  echo "SERVICE_ON_ICE_NOT_RUNNING" >> /var/log/ping.log

								echo "------------------------------------" >> /var/log/ping.log
                                                            fi



                                           fi

                                fi              
              
                fi
        fi

sleep 1s

done





                       

