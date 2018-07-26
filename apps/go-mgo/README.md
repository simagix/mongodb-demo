# Golang Example

## Spin up `mongod`
```
mongod --dbpath ~/ws/demo --logpath ~/ws/demo/mongod.log --fork --auth --sslCAFile /etc/ssl/certs/ca.pem --sslPEMKeyFile /etc/ssl/certs/server.pem --sslMode requireSSL --bind_ip_all
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

## Test GO Client
Edit `client.go` as needed.

```
$ go run client.go
number of red cars: 67
```
