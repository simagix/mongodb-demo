#! /usr/bin/env python
# Copyright 2018 Kuei-chun Chen. All rights reserved.

import pymongo
from pymongo import MongoClient

if __name__ == "__main__":
    client = MongoClient('localhost:27017',
                            username="user",
                            password="password",
                            ssl=True,
                            ssl_ca_certs='/etc/ssl/certs/ca.pem',
                            ssl_certfile='/etc/ssl/certs/client.pem',
                            ssl_keyfile='/etc/ssl/certs/client.pem')

    db = client.keyhole
    collection = db.cars
    count = collection.find({'color': 'Red'}).count(True)
    print "number of red cards: %d" % count
