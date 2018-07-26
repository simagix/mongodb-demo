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
keyhole --uri mongodb://user:password@localhost/keyhole?authSource=admin --seed --drop \
  --ssl --sslCAFile /etc/ssl/certs/ca.pem --sslPEMKeyFile /etc/ssl/certs/client.pem
```

## Test Ruby Script
Edit `client.rb` as needed.

```
$ ruby client.rb
number of red cars: 67
```
