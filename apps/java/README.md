# Java Example

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

## Test Java Client
Edit `Client.java` as needed.

### Import to Keystore

```
openssl pkcs12 -export -out /etc/ssl/certs/keystore.p12 -inkey /etc/ssl/certs/client.pem -in /etc/ssl/certs/client.pem
keytool -importkeystore -destkeystore /etc/ssl/certs/keystore.jks -srcstoretype PKCS12 -srckeystore /etc/ssl/certs/keystore.p12
keytool -importcert -trustcacerts -file /etc/ssl/certs/ca.pem -keystore truststore.jks
```

### Run Using Gradle
```
$ gradle --quiet run
number of red cars: 67
```
