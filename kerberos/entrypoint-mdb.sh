#! /bin/bash
# Copyright 2019 Kuei-chun Chen. All rights reserved.
: ${REALM:=EXAMPLE.COM}
: ${ADMIN_USER:=admin}
: ${ADMIN_PASSWORD:=admin}
: ${SHARED:=/repo}

mkdir -p /var/log/mongodb /var/log/kerberos
# Create an user
mongod --dbpath /data/db --logpath /var/log/mongodb/mongod.log --bind_ip_all --fork
mongo mongodb://localhost/ --eval "db.getSisterDB('\$external').createUser({ user: 'mdb/analytic@${REALM}', roles: [ { role: 'readWrite', db: 'admin' } ]})"
mongo 'mongodb://localhost/admin' --eval 'db.shutdownServer()'

# Create princials
pass=$(openssl rand -hex 8)
mkdir -p $SHARED
keytab="$SHARED/mongodb.keytab"
clientkt="$SHARED/mdb.keytab"
# principal for mongod
kadmin -r $REALM -p $ADMIN_USER/admin -w $ADMIN_PASSWORD addprinc -pw $pass mongodb/mongo.simagix.com
printf "%b" "addent -password -p mongodb/mongo.simagix.com -k 1 -e aes256-cts\n$pass\nwrite_kt $keytab" | ktutil
# principal for user
kadmin -r $REALM -p $ADMIN_USER/admin -w $ADMIN_PASSWORD addprinc -pw $pass mdb/analytic
# use ktutil to create a keyfile for mongod to use
printf "%b" "addent -password -p mdb/analytic -k 1 -e aes256-cts\n$pass\nwrite_kt $clientkt" | ktutil

# Start mongod with auth and GSSAPI
env KRB5_KTNAME=$keytab \
  mongod --dbpath /data/db --logpath /var/log/mongodb/mongod.log --bind_ip_all --fork \
  --auth --setParameter authenticationMechanisms=GSSAPI

# test with a client
kinit mdb/analytic@$REALM -kt $clientkt
mongo --host mongo.simagix.com --authenticationMechanism=GSSAPI \
  --authenticationDatabase='$external' --username "mdb/analytic@$REALM" \
  --eval 'db.version()'

# test using a connection string, %2f: / and %40: @
mongo "mongodb://mdb%2fanalytic%40$REALM:xxx@mongo.simagix.com/?authMechanism=GSSAPI&authSource=\$external" \
  --eval 'db.version()'

# keep the instance up
tail -F /var/log/mongodb/mongod.log
