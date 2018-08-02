// Copyright 2018 Kuei-chun Chen. All rights reserved.

const MongoClient = require('mongodb').MongoClient;
const assert = require('assert');
var fs = require('fs');
var cabuf = fs.readFileSync("/etc/ssl/certs/ca.pem");
var clientbuf = fs.readFileSync("/etc/ssl/certs/client.pem");

var options = {
  useNewUrlParser: true,
  sslCA: cabuf,
  sslKey: clientbuf,
  sslCert: clientbuf,
  sslValidate: false
};


// Connection URL
const url = 'mongodb://user:password@localhost:27017/keyhole?authSource=admin&ssl=true';

// Use connect method to connect to the server
MongoClient.connect(url, options, function(err, client) {
  assert.equal(null, err);
  console.log("Connected successfully to server");

  const db = client.db('keyhole');
  db.collection('cars').find({'color': 'Red'}).toArray(function(err, docs) {
    console.log('number of red cars: ' + docs.length);
    client.close();
  });

});
