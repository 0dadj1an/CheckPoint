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
#rint total/500

client = MongoClient('mongodb://192.168.0.2:27017/')
db = client['protectionsDatabase']

#collection = db['protectionsCollection']



for i in range(0,total):
    payload_list['offset']=offset
    payload_list['limit']=500
    response = (requests.post(url+"show-threat-protections", json=payload_list, headers=headers, verify=False)).json()
    offset = offset + 500
    
    if response['total'] is 0:
        print "koncim"
        cursor = db.protectionsCollection.find()
        
        for document in cursor:
            print(document)
        print db.protectionsCollection.count()
        break
        
    else:
        #print response
        count = 0
        for int in response['protections']:
            count = count + 1
            #db.collection.update(response['protections'], response['protections'], {upsert: true})
            print int
            print db.protectionsCollection.update(int, int, upsert=True)
            
            
        print count
        print db.protectionsCollection.count()