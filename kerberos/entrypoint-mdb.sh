#! /bin/bash

mkdir -p /var/log/kerberos /var/log/mongodb
mongod --dbpath /data/db --logpath /var/log/mongodb/mongod.log --bind_ip_all --fork
mongo 'mongodb://localhost/' --eval 'db.getSisterDB("\$external").createUser({ user: "application/reporting@SIMAGIX.COM", roles: [ { role: "read", db: "records" } ]})'
mongo 'mongodb://localhost/admin' --eval 'db.shutdownServer()'

pass="mongo123"
keytab="/mongodb.keytab"
kadmin -r SIMAGIX.COM -p admin/admin -w admin addprinc -pw $pass mongodb/mongo.simagix.com
kadmin -r SIMAGIX.COM -p admin/admin -w admin addprinc -pw $pass application/reporting
printf "%b" "addent -password -p mongodb/mongo.simagix.com -k 1 -e aes256-cts\n$pass\naddent -password -p application/reporting -k 1 -e aes256-cts\n$pass\nwrite_kt $keytab" | ktutil
kinit application/reporting@SIMAGIX.COM -kt $keytab

env KRB5_KTNAME=$keytab mongod --dbpath /data/db --logpath /var/log/mongodb/mongod.log --bind_ip_all --fork \
  --auth --setParameter authenticationMechanisms=GSSAPI

mongo --host mongo.simagix.com --authenticationMechanism=GSSAPI \
  --authenticationDatabase='$external' --username "application/reporting@SIMAGIX.COM" \
  --eval 'db.version()'

tail -F /var/log/mongodb/mongod.log
