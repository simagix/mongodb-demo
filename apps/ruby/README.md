# Ruby Example

## Install MongoDB Ruby Driver
```
sudo gem install mongo -v 2.6.1
```

## Spin up `mongod`
```
mongod --dbpath ~/ws/ruby --logpath ~/ws/ruby/mongod.log --fork --auth --sslCAFile /etc/ssl/certs/ca.pem --sslPEMKeyFile /etc/ssl/certs/server.pem --sslMode requireSSL --bind_ip_all
```

### Create a User
```
db.createUser({ user: 'user', pwd: 'password', roles: ['root'] })
```

### Login from Mongo shell
```
mongo 'mongodb://user:password@localhost:27017/keyhole?authSource=admin' --ssl --sslCAFile /etc/ssl/certs/ca.pem --sslPEMKeyFile /etc/ssl/certs/client.pem
```

### Seed Data
```
keyhole --uri mongodb://user:password@localhost/keyhole?authSource=admin --seed --drop --ssl --sslCAFile /etc/ssl/certs/ca.pem --sslPEMKeyFile /etc/ssl/certs/client.pem
```

## Test Ruby Script
Edit `client.rb` as needed.

```
$ ruby client.rb
D, [2018-07-25T10:15:03.439179 #48269] DEBUG -- : MONGODB | EVENT: #<Mongo::Monitoring::Event::TopologyOpening topology=Unknown>
D, [2018-07-25T10:15:03.439234 #48269] DEBUG -- : MONGODB | Topology type 'unknown' initializing.
D, [2018-07-25T10:15:03.439316 #48269] DEBUG -- : MONGODB | EVENT: #<Mongo::Monitoring::Event::ServerOpening address=localhost:27017 topology=Unknown>
D, [2018-07-25T10:15:03.439343 #48269] DEBUG -- : MONGODB | Server localhost:27017 initializing.
D, [2018-07-25T10:15:03.525197 #48269] DEBUG -- : MONGODB | EVENT: #<Mongo::Monitoring::Event::TopologyChanged prev=Unknown new=Single>
D, [2018-07-25T10:15:03.525246 #48269] DEBUG -- : MONGODB | Topology type 'unknown' changed to type 'single'.
D, [2018-07-25T10:15:03.525317 #48269] DEBUG -- : MONGODB | EVENT: #<Mongo::Monitoring::Event::ServerDescriptionChanged>
D, [2018-07-25T10:15:03.525380 #48269] DEBUG -- : MONGODB | Server description for localhost:27017 changed from 'unknown' to 'standalone'.
D, [2018-07-25T10:15:03.525445 #48269] DEBUG -- : MONGODB | EVENT: #<Mongo::Monitoring::Event::TopologyChanged prev=Single new=Single>
D, [2018-07-25T10:15:03.525471 #48269] DEBUG -- : MONGODB | There was a change in the members of the 'single' topology.
D, [2018-07-25T10:15:03.526165 #48269] DEBUG -- : MONGODB | localhost:27017 | test.find | STARTED | {"find"=>"cars", "filter"=>{"color"=>"Red"}, "lsid"=>{"id"=><BSON::Binary:0x70329034469680 type=uuid data=0x41ee36e04c584ca2...>}}
D, [2018-07-25T10:15:03.569169 #48269] DEBUG -- : MONGODB | localhost:27017 | admin.saslStart | STARTED | {}
D, [2018-07-25T10:15:03.576482 #48269] DEBUG -- : MONGODB | localhost:27017 | admin.saslStart | SUCCEEDED | 0.007s
D, [2018-07-25T10:15:03.601155 #48269] DEBUG -- : MONGODB | localhost:27017 | admin.saslContinue | STARTED | {}
D, [2018-07-25T10:15:03.602044 #48269] DEBUG -- : MONGODB | localhost:27017 | admin.saslContinue | SUCCEEDED | 0.001s
D, [2018-07-25T10:15:03.602563 #48269] DEBUG -- : MONGODB | localhost:27017 | admin.saslContinue | STARTED | {}
D, [2018-07-25T10:15:03.603927 #48269] DEBUG -- : MONGODB | localhost:27017 | admin.saslContinue | SUCCEEDED | 0.001s
D, [2018-07-25T10:15:03.604345 #48269] DEBUG -- : MONGODB | localhost:27017 | test.find | SUCCEEDED | 0.078s

D, [2018-07-25T10:15:03.605000 #48269] DEBUG -- : MONGODB | localhost:27017 | admin.endSessions | STARTED | {"endSessions"=>[{"id"=><BSON::Binary:0x70329034469680 type=uuid data=0x41ee36e04c584ca2...>}]}
D, [2018-07-25T10:15:03.605437 #48269] DEBUG -- : MONGODB | localhost:27017 | admin.endSessions | SUCCEEDED | 0.000s
```
