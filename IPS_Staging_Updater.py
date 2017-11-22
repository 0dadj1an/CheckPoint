#!/bin/python

'''
This code is for Check Point R80.10 staging IPS signatures update. You need to have csv file with all staging signatures, you can get it via csv export from
SmartConsole.
@author: ivohrbacek@gmail.com / ivo.hrbacek@ixperta.com
'''

import csv 
import pprint
import json
import os, time, datetime, sys, shutil
import requests
import ConfigParser
import sys


class IPS_Staging_Updater(object):
    
    def __init__(self, profile_name, protection_name, sid, url):
        self.profile_name = profile_name
        self.protection_name = protection_name
        self.sid = sid
        self.url = url
        
    
    def get_profile(self):
        return self.profile_name
    def get_protection_name(self):
        return self.protection_name
    
    def update(self):
        payload_list={}
        override_list = [{'profile': self.profile_name,'action':'Prevent'}] 
        payload_list['overrides']=override_list
        payload_list['name']=self.protection_name
        
        #print payload_list
        
        headers = {
            'content-type': "application/json",
            'Accept': "*/*",
            'x-chkp-sid': self.sid,
        }
        response = requests.post(self.url+"set-threat-protection", json=payload_list, headers=headers, verify=False)
        return response.json()
        

class CSV_Importer_to_List(object):
    
    def __init__(self, file_name):
        self.filename = file_name
        self.dic_list = []
        try:
            self.reader = csv.DictReader(open(file_name, 'rb'))
            for line in self.reader:
                self.dic_list.append(line)
        except IOError:
            print "csv file you specified does not exists"
            sys.exit(1)
            
    def get_csv_list(self):
        return self.dic_list    
    

class Info_Loader(object):
    
    def __init__(self):
      self.default_csv_os_path = raw_input("write full csv path in this format: C:/csv/test.csv :" + '\n')
      print("###########################################################################################################################################")
      
      self.profile_name = raw_input("write profile name" + '\n')
      print("###########################################################################################################################################")
          
    def get_path(self):
        return self.default_csv_os_path
    
    def get_profile_name(self):
        return self.profile_name
    

class Connector():
    @classmethod
    
    def task(cls,sid,url,task):
        payload_list={}
        payload_list['task-id']=task
        headers = {
            'content-type': "application/json",
            'Accept': "*/*",
            'x-chkp-sid': sid,
        }
        response = requests.post(url+"show-task", json=payload_list, headers=headers, verify=False)
        return response
    
    def __init__(self):
        
         self.sid=""
         self.task = ""
         config = ConfigParser.ConfigParser()
         default_cpi_os_path = raw_input("write full cp.ini path where url and credentials for mgmt server are stored in this format: C:/csv/cp.ini :" + '\n')
         try:
             
             config.read(default_cpi_os_path) #read from cp.ini file
             self.url=config.get('config','url',0)
             self.user=config.get('config','user',0)
             self.passowrd=config.get('config','password',0)
         
             payload_list={}
             payload_list['user']=self.user
             payload_list['password']=self.passowrd
             headers = {
             'content-type': "application/json",
              'Accept': "*/*",
             }
         except ConfigParser.NoSectionError:
             print "there is no cp.ini file or config section is missing"
             sys.exit(1)
        
         try:
             self.response = requests.post(self.url+"login", json=payload_list, headers=headers, verify=False)
                
         except requests.exceptions.ConnectionError:
             print "can not connect to mgmt server!!!"
             sys.exit(1)
             
             
    def logout(self):
        
        payload_list={}
        headers = {
            'content-type': "application/json",
            'Accept': "*/*",
            'x-chkp-sid': self.sid,
        }
        self.response = requests.post(self.url+"logout", json=payload_list, headers=headers, verify=False)
        return self.response
    
    def publish(self):
        payload_list={}
        headers = {
            'content-type': "application/json",
            'Accept': "*/*",
            'x-chkp-sid': self.sid,
        }
        self.response = requests.post(self.url+"publish", json=payload_list, headers=headers, verify=False)
        
        publish_text=json.loads(self.response.text)
        print "publish_text:"
        print publish_text
        
        show_task=Connector.task(self.sid,self.url,publish_text['task-id'])
        print "show_task_text"
        print show_task
        
        show_task_text = json.loads(show_task.text)
        print "show_task_text"
        print show_task_text
        
        print json.loads(show_task.text)
        
        while show_task_text['tasks'][0]['status'] == "in progress":
            print " publish status = ", show_task_text['tasks'][0]['progress-percentage']
            time.sleep(3)
            show_task=Connector.task(self.sid,self.url,publish_text['task-id'])
            show_task_text=json.loads(show_task.text)
            print " publish status = ", show_task_text['tasks'][0]['progress-percentage'] , show_task_text['tasks'][0]['status']
        
        return self.response
        
             
    def get_responce(self):
       
        if self.response.status_code == 200:
            sid_out=json.loads(self.response.text)
            self.sid = sid_out['sid']
            return self.sid 
        else:
            print "There is no SID, connection problem to mgmt server"
            print self.response.status_code
            
    def get_url(self):
        '''
        This is method for url return
        '''
        return self.url




def main():
    
    """This is main method responsible for getting all atributes via instance of Info_Loader class, formating csv to list of dics via instance of CSV_Importer class and connect 
    to mgmt server via instance of Connector class.
    Finally every staging signature is updated via instance of IPS_Staging_Updater class
    
    """
    print("This is R80.10 IPS signature staging updater script. It supposes you have downloaded csv file from mgmt server with staging signatures..")
    print("###########################################################################################################################################")
    info_data = Info_Loader() # load profile name/ path to csv file via I/O input
    path_url = info_data.get_path() # get file path
    profile_name = info_data.get_profile_name() # get profile name
    csv_local = CSV_Importer_to_List(path_url) # transform csv to list of dictionaries
    list = csv_local.get_csv_list() # save list
    
    connect = Connector() # connector instance
    sid = connect.get_responce() # save session ID
    #print "SID is : "+ sid + '\n'
    
    print time.time()
    print "updating all staging signatures..."
    
    # defining logging
    old_stdout = sys.stdout
    log_file = open("log.log","w")
    
    counter = 0
    # start logging
    sys.stdout = log_file
    for item in list:
        try: 
            print item ['Protection'] + " / "+ "profile name is: " + profile_name + " /" + "action is: " + item [profile_name]
            protection_name = item ['Protection']
            update = IPS_Staging_Updater(profile_name, protection_name, sid, connect.get_url())
            print update.update()
            counter = counter + 1
            
        except KeyError:
            print "There is no profile name:" + profile_name + '\n'
    
    
    print "Publish.."
    connect.publish()
    
    print "Logout.."
    print connect.logout()
    
    # end of logging
    sys.stdout = old_stdout
    log_file.close()
    
    print time.time()
    print "done, signatures updated: " + str(counter)
    
if __name__ == "__main__":
    main()

        
        