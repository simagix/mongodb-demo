# Kerberos and MongoDB Enterprise Integration
Demo how MongoDB Enterprise server uses Kerberos for authentication and LDAP for authorization.

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
ldapsearch -x cn=mdb -b dc=simagix,dc=local -H ldaps://ldap.simagix.com
```

### Validate /etc/mongod.conf
```
mongoldap --config /etc/mongod.conf --user mdb@SIMAGIX.COM --password secret
```

### Connect with mongo
```
mongo "mongodb://mdb%40$REALM:xxx@mongo.simagix.com/?authMechanism=GSSAPI&authSource=\$external"
```

Or

```
mongo "mongodb://mdb%40$REALM:xxx@mongo.simagix.com/?authMechanism=GSSAPI&authSource=\$external" \
  --ssl --sslCAFile /ca.crt --sslPEMKeyFile /client.pem
```

Check connection status:
```
db.runCommand({connectionStatus : 1})
```

## x509 Certificates
### Certificate Creation
```
create_certs.sh ldap.simagix.com mongo.simagix.com

certs/
├── ca.crt
├── client.pem
├── ldap.simagix.com.pem
└── mongo.simagix.com.pem
```

### Enable TLS
Lines added to */etc/openldap/ldap.conf* on both ldap.simagix.com and mongo.simagix.com.
```
TLS_REQCERT never
TLS_CACERT /server.pem
```
