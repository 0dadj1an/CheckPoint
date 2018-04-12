
#author     :ivo.hrbacek@ixperta.com
#version    :0.0001


import csv
global VLAN


def generaeClishCommon():
    
    interface = 'eth3 ' #raw_input("zadej jmeno hlavniho interface: \n")
    stringCommon = 'clish -c '
    stringCommandBeginEnd = '\''
    stringCommand = 'set interface '+ interface + 'state on'
    stringEnd = ' -s'
    
     
    return stringCommon + stringCommandBeginEnd + stringCommand + stringCommandBeginEnd + stringEnd

def generateInterface(IP, mask):
    
     ip = removeLastOctect(IP)
     interface = 'eth3' 
     stringCommon = 'clish -c '
     stringCommandBeginEnd = '\''
     stringCommand = 'set interface '+ interface + '.' + VLAN + ' ipv4-address ' + ip + ' mask-length ' + mask
     stringEnd = ' -s'
     
     return stringCommon + stringCommandBeginEnd + stringCommand + stringCommandBeginEnd + stringEnd
    
def generateVlan(vlan):
     global VLAN
     VLAN = vlan 
     interface = 'eth3 ' 
     stringCommon = 'clish -c '
     stringCommandBeginEnd = '\''
     stringCommand = 'add interface '+ interface + 'vlan ' + vlan 
     stringEnd = ' -s'
     
     return stringCommon + stringCommandBeginEnd + stringCommand + stringCommandBeginEnd + stringEnd
 
def removeLastOctect(IP):
    
    checker = 1
    ip4_sections = IP.split(".")
    #print ip4_sections
    IP = ip4_sections[0]+ '.'+ ip4_sections[1]+ '.' +ip4_sections[2] +'.1'
    return IP
    

def loadCSV(path):
    reader = csv.DictReader(open(path, 'rb'))
    dic_list = []

    for line in reader:
         dic_list.append(line)

    #pprint.pprint(dic_list)
    return dic_list
      

def main():
    #print generaeClishCommon()
    
    
    try:
        object_list = loadCSV('test01.csv')
        for item in object_list:
             if ((item['L3 interface defined on'] == 'fw' or item['L3 interface defined on'] == 'fw+core' or item['L3 interface defined on'] == 'fw+ASA') and item['Location'] == 'Brno'): #and item['Network category'] != 'INT'):
                 vlan = item['VLAN']
                 ip = item['Network']
                 maska = item ['Mask length']
                 print generateVlan(vlan)
                 print generateInterface(ip, maska)
            
        
    except IOError:
         print "bad csv file path"
         output = session.logout()
         print output.status_code
         sys.exit()
         
         
  
   
if __name__ == "__main__":
    main()