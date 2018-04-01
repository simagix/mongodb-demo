#! /usr/bin/env python
# change_stream.py
# Author: Ken Chen
#   3/31/2018 - first created
#

import json
import paho.mqtt.publish as publish
import pymongo
from pymongo import MongoClient
import sys
import time

client = None
db = None
collection = None

def init(mongo_uri):
    global client
    global db
    global collection
    client = MongoClient(mongo_uri)
    db = client.orders
    collection = db.products

if __name__ == "__main__":
    mongo_uri = 'mongodb://localhost:27017/test?replicaSet=replset'
    if len(sys.argv) > 1:
        mongo_uri = sys.argv[1]
    init(mongo_uri)
    try:
        for change in collection.watch():
            doc = {"op": change['operationType'], "_id":  change['documentKey']['_id'], "lang": "python"}
            payload = json.dumps(doc)
            print(payload)
            publish.single("simagix/cs/test", payload, hostname="test.mosquitto.org")
    except pymongo.errors.PyMongoError:
        console.log("error")
        pass

