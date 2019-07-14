#! /bin/bash
# Copyright 2019 Kuei-chun Chen. All rights reserved.
: ${REALM:=EXAMPLE.COM}
: ${ADMIN_USER:=admin}
: ${ADMIN_PASSWORD:=admin}
: ${SHARED:=/repo}

mkdir -p /var/log/mongodb /var/log/kerberos
# Create an user
mongod --dbpath /data/db --logpath /var/log/mongodb/mongod.log --bind_ip_all --fork
mongo mongodb://localhost/ --eval "db.getSisterDB('\$external').createUser({ \
  user: 'mdb@${REALM}', \
  roles: [ { role: 'readWrite', db: 'admin' } ]})"

mongo mongodb://localhost/ --eval "db.getSisterDB('admin').createRole({ \
  role: 'cn=DBAdmin,ou=Groups,dc=simagix,dc=local', \
  privileges: [], \
  roles: [ 'userAdminAnyDatabase', 'clusterAdmin', 'readWriteAnyDatabase', 'dbAdminAnyDatabase' ] })"
mongo 'mongodb://localhost/admin' --eval 'db.shutdownServer()'

# Create princials
pass=$ADMIN_PASSWORD
#pass=$(openssl rand -hex 8)
mkdir -p $SHARED
keytab="$SHARED/mongodb.keytab"
# principal for mongod
kadmin -r $REALM -p $ADMIN_USER/admin -w $ADMIN_PASSWORD addprinc -pw $pass mongodb/mongo.simagix.com
printf "%b" "addent -password -p mongodb/mongo.simagix.com -k 1 -e aes256-cts\n$pass\nwrite_kt $keytab" | ktutil

# Enable TLS
echo "TLS_REQCERT never" >> /etc/openldap/ldap.conf
echo "TLS_CACERT /server.pem" >> /etc/openldap/ldap.conf

# Start mongod with auth and GSSAPI
env KRB5_KTNAME=$keytab mongod -f /etc/mongod.conf

# principal for user
clientkt="$SHARED/mdb.keytab"
kadmin -r $REALM -p $ADMIN_USER/admin -w $ADMIN_PASSWORD addprinc -pw $pass mdb
# use ktutil to create a keyfile for mongod to use
printf "%b" "addent -password -p mdb -k 1 -e aes256-cts\n$pass\nwrite_kt $clientkt" | ktutil
kinit mdb@$REALM -kt $clientkt
# test with a client
mongo --host mongo.simagix.com --authenticationMechanism=GSSAPI \
  --authenticationDatabase='$external' --username "mdb@$REALM" \
  --ssl --sslCAFile /ca.crt --sslPEMKeyFile /client.pem \
  --eval 'db.version()'

# test using a connection string, %2f: / and %40: @
mongo "mongodb://mdb%40$REALM:xxx@mongo.simagix.com/?authMechanism=GSSAPI&authSource=\$external" \
  --ssl --sslCAFile /ca.crt --sslPEMKeyFile /client.pem \
  --eval 'db.getSisterDB("admin").getRoles()'

# keep the instance up
tail -F /var/log/mongodb/mongod.log
