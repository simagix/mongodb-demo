#! /bin/bash
mkdir -p data/rs{1,2,3}/db
init=0
if [ -z "$(ls -A data/rs1/db)" ]; then
    init=1
fi
for i in 1 2 3
do
    dbpath="rs${i}"
    port="2702${i}"
    cat mongod.conf | sed -e "s/_path_/data\/${dbpath}/g" -e "s/27017/${port}/" > data/$dbpath/mongod.conf
    mongod -f data/$dbpath/mongod.conf
done

if [ $init -eq 1 ]; then
    sleep 5
    mongo --port 27021 --sslCAFile /etc/ssl/certs/ca.crt --ssl --sslPEMKeyFile /etc/ssl/certs/client.pem \
        --eval 'rs.initiate( { _id: "rs", members: [ { _id: 0, host: "localhost:27021" }, { _id: 1, host: "localhost:27022" }, { _id: 2, host: "localhost:27023" }] } )'

    sleep 5
    mongo mongodb://localhost:27021/admin?replicaSet=rs \
        --sslCAFile /etc/ssl/certs/ca.crt --ssl --sslPEMKeyFile /etc/ssl/certs/client.pem \
        --eval 'db.getSisterDB("$external").runCommand( {
            createUser:"emailAddress=ken.chen@simagix.com,CN=ken.chen,OU=Consulting,O=Simagix,L=Atlanta,ST=Georgia,C=US" ,
            roles: [{role: "root", db: "admin" }] })'
fi

mongo mongodb://localhost:27021/admin?replicaSet=rs \
    --sslCAFile /tmp/certs/ca.crt --ssl --sslPEMKeyFile /tmp/certs/client.pem \
    --authenticationMechanism MONGODB-X509 --authenticationDatabase "\$external" \
    -u "emailAddress=ken.chen@simagix.com,CN=ken.chen,OU=Consulting,O=Simagix,L=Atlanta,ST=Georgia,C=US" \
    --eval 'rs.status()'
