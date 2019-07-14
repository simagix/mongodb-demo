# Kerberos and MongoDB Enterprise Integration
Demo how MongoDB Enterprise server integrates with Kerberos 5 server.

## build
```
docker build -t simagix/kerberos -f Dockerfile-krb .
docker build -t simagix/openldap -f Dockerfile-ldap .
docker build -t simagix/mongo-kerberos -f Dockerfile-mdb .
```

## Startup
```
docker-compose up
```

## Shutdown
```
docker-compose down
```

## Test
### Search LDAP
```
ldapsearch -x cn=mdb -b dc=simagix,dc=local -H ldap://ldap.simagix.com
```

### Validate /etc/mongod.conf
```
mongoldap --config /etc/mongod.conf --user mdb@SIMAGIX.COM --password secret
```

### Connect with mongo
```
mongo "mongodb://mdb%40$REALM:xxx@mongo.simagix.com/?authMechanism=GSSAPI&authSource=\$external"
```

Check connection status:
```
db.runCommand({connectionStatus : 1})
```
