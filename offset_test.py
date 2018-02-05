from IPS_Staging_Updater2 import Connector
import requests
import json
from pymongo import MongoClient

connect = Connector() # connector instance
sid = connect.get_responce() # save session ID

payload_list={}

offset = 0
limit = 500

payload_list['offset']=offset
payload_list['limit']=500

url = connect.get_url()
              
headers = {
            'content-type': "application/json",
            'Accept': "*/*",
            'x-chkp-sid': sid,
}


# first iterace 
response = requests.post(url+"show-threat-protections", json=payload_list, headers=headers, verify=False)
list = response.json()
total = list['total']
print total/500

client = MongoClient('mongodb://192.168.0.2:27017/')
db = client['protections-database']

collection = db['protections-collection']



for i in range(0,total):
    payload_list['offset']=offset
    payload_list['limit']=200
    response = (requests.post(url+"show-threat-protections", json=payload_list, headers=headers, verify=False)).json()
    offset = offset + 500
    
    if response['total'] is 0:
        print "koncim"
        cursor = db.protections-collection.find()
        for document in cursor:
            print(document)
            print(Ahoj)
        break
        
    else:

        #print response['protections']
        collection.insert(response['protections'])
        
    








        