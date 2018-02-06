#!/bin/python

"""
This code is for Check Point R80.10 IPS signatures update. You need to have csv file with all staging signatures, you can get it via csv export from
SmartConsole.
@author: ivohrbacek@gmail.com / ivo.hrbacek@ixperta.com
"""

import csv 
import pprint
import json
import os, time, datetime, sys, shutil
import requests
import ConfigParser
import sys


class IPS_Staging_Updater(object):
   
    
    def __init__(self, profile_name_list, protection_name, sid, url):
        """
         constructor method setting all needed info for update session 
         defined protection name, session id, url and override list for modification
         
        """
        self.protection_name = protection_name # protection name
        self.sid = sid # session ID
        self.url = url # url for mgmt aerver api
        self.override_list = profile_name_list # override list according to api documentation
        
    
    def get_protection_name(self):
        """
        returns protection name  
        """
        return self.protection_name
    
    def get_override_list(self):
        """
        returns protection profile list with overrides  
        """
        return self.override_list
        
    def update(self):
        """
        method for signature update,
        call via http request web api with parameters and modify signature settings 
        """
        payload_list={}
         
        payload_list['overrides']=self.override_list
        payload_list['name']=self.protection_name
        
        
        
        headers = {
            'content-type': "application/json",
            'Accept': "*/*",
            'x-chkp-sid': self.sid,
        }
        response = requests.post(self.url+"set-threat-protection", json=payload_list, headers=headers, verify=False)
        print response.json()
        return response.json()
        

class CSV_Importer_to_List(object):
    
    def __init__(self, file_name):
        """
        constructor for loading csv file and transform to list data structure (include dictionaries) 
        """
        
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
        """
        returns list of dictionaries - transformed data from scv to list f dictionaries 
        """
        return self.dic_list    
    

class Info_Loader(object):
    
    def __init__(self):
      """
        constructor for info data. loads user inputs like profile name and action 
      """  
      self.profile_list = [] # 
      self.default_csv_os_path =raw_input("write full csv path in this format: C:/xxx/xxx.csv :" + '\n') # insert csv file
      print("###########################################################################################################################################")
      self.profile_count = raw_input("write number of profiles you want to modify:" + '\n') # insert number of profiles to modify
      print("###########################################################################################################################################")
      
      local_counter = 0 # local counter to check how many profiles were defined and how many are saved
      
      while True: # load data till you hit final number of profiles
          if local_counter == int(self.profile_count):# if local = define than break 
              break
          else:
              dic_a = {}# help dictionary
              dic_a.update({'profile': raw_input("write profile name :" + '\n'), 'action':raw_input("write action :" + '\n'), 'track': 'log'}) # put data to dictionary
              self.profile_list.append(dic_a) # put dictionary to list
              local_counter = local_counter + 1 # reset conter
              print("###########################################################################################################################################")
      
         
    def get_path(self):
        """
        returns csv patht 
        """
        return self.default_csv_os_path
    
    def get_profile_name(self):
        """
        returns profile name 
        """
        return self.profile_name
    
    def get_profile_list(self):
        """
        returns protection name profile list 
        """
        return self.profile_list
    
    def det_profile_count(self):
        """
        returns protection name profile list 
        """
        return self.profile_count
    

class Connector():
    @classmethod
    
    def task(cls,sid,url,task):
        """
        this is help method shich is checking task status
        """
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
         """
         """
        
         self.sid=""
         self.task = ""
         config = ConfigParser.ConfigParser()
         default_cpi_os_path = 'C:/csv/cp.ini'#raw_input("write full cp.ini path where url and credentials for mgmt server are stored in this format: C:/xxx/cp.ini :" + '\n')
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
    
    ####
    how to log to file:
    import sys
    old_stdout = sys.stdout
    
    log_file = open("message.log","w")
    
    sys.stdout = log_file
    
    print "this will be written to message.log"
    
    sys.stdout = old_stdout
    
    log_file.close()
    ###
    
    
    """
    print("This is R80.10 IPS signature updater script. It supposes you have downloaded csv file from mgmt server with protection names..")
    print("###########################################################################################################################################")
    
    info_data = Info_Loader() # load profile name/ path to csv file via I/O input
    path_url = info_data.get_path() # get file path
    
    profile_list = info_data.get_profile_list() # get list with profiles and parameters
 
    
    csv_local = CSV_Importer_to_List(path_url) # transform csv to list of dictionaries
    list = csv_local.get_csv_list() # save list
    
    connect = Connector() # connector instance
    sid = connect.get_responce() # save session ID
    
    
    print "updating all signatures..."
    
    # defining logging
    old_stdout = sys.stdout
    log_file = open("log.log","w")
    
    counter = 0 # signature counter initialization to zero
    
    # start logging
    sys.stdout = log_file
    print "SID is : "+ sid + '\n'
    print "Profile list is:"
    print profile_list
    
    for item in list: # iteration over items in csv file
        try: 
            print item ['Protection']  # print protection name
            protection_name = item ['Protection']
            update = IPS_Staging_Updater(profile_list, protection_name, sid, connect.get_url()) # create instance of Updater calls
            print update.update() # call update and print te responce
            counter = counter + 1 # reset counter
            
        except KeyError: # if there us a key error in profile name ()
            """
            this has to be fixed, i need to ceck profile names and compare if exist
            """
            print "There is no profile name:" + profile_name + '\n'
    
    
    print "Publish.."
    connect.publish()
    
    print "Logout.."
    print connect.logout()
    
    # end of logging
    sys.stdout = old_stdout
    log_file.close()
    
    print "done, signatures updated: " + str(counter)
    
if __name__ == "__main__":
    main()

        
        