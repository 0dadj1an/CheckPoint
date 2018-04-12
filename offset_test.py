"""
offset testing and loading datta into mongodb

ivohrbacek@gmail.com
"""

from IPS_Staging_Updater2 import Connector
import requests
import json
from pymongo import MongoClient
import time





start_time = time.time()

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

client = MongoClient('mongodb://192.168.0.2:27017/', maxPoolSize=200)
db = client['protectionsDatabase']

#collection = db['protectionsCollection']



for i in range(0,total):
    payload_list['offset']=offset
    payload_list['limit']=500

    # avoid connectovity interruption
    done=False
    while not done:
        try:
            response = (requests.post(url+"show-threat-protections", json=payload_list, headers=headers, verify=False)).json()
        except:
            print "connection broken, trying again"
        else:
            done=True
    # avoid connectovity interruption

    offset = offset + 500
    if response['total'] is 0:
        print "koncim"
        cursor = db.protectionsCollection.find()
        
        '''
        for document in cursor:
            print(document)
        '''
        print db.protectionsCollection.count()
        break
        
    else:
        #print response
        count = 0
        '''
        def gen(int):
            for i in int:
                yield int

        g = gen(response['protections'])
        print type(g)
        print g.next()

        #db.protectionsCollection.update({'_id': int['name']}, g.next() , upsert=True)
        '''
        for int in response['protections']:
            count = count + 1
            #db.collection.update(response['protections'], response['protections'], {upsert: true})
            #print int
            db.protectionsCollection.update({'_id': int['name']}, int, upsert=True)
         
        print count
        print db.protectionsCollection.count()
        print("--- %s seconds ---" % (time.time() - start_time))    
            
   