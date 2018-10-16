#! /bin/bash
mkdir -p data/rs{1,2,3}/db
init=0
if [ -z "$(ls -A data/rs1/db)" ]; then
    init=1
fi

if [ "$CERTS_ROOT" = "" ]; then
    CERTS_ROOT="/etc/ssl"
fi

cat > mongod.conf << EOF
systemLog:
  destination: file
  logAppend: true
  path: _path_/mongod.log
storage:
  dbPath: _path_/db
  journal:
    enabled: true
processManagement:
  fork: true
  pidFilePath: /tmp/mongod-27017.pid
net:
  port: 27017
  bindIp: 0.0.0.0
  ssl:
    mode: requireSSL
    PEMKeyFile: $CERTS_ROOT/certs/server.pem
    clusterFile: $CERTS_ROOT/certs/server.pem
    CAFile: $CERTS_ROOT/certs/ca.pem
replication:
  replSetName: rs
security:
  authorization: enabled
  clusterAuthMode: x509
EOF

HOSTNAME=$(hostname -f)

for i in 1 2 3
do
    dbpath="rs${i}"
    port="2702${i}"
    cat mongod.conf | sed -e "s/_path_/data\/${dbpath}/g" -e "s/27017/${port}/" > data/$dbpath/mongod.conf
    mongod -f data/$dbpath/mongod.conf
done

if [ $init -eq 1 ]; then
    sleep 5
    echo "rs.initiate()"
    mongo mongodb://localhost:27021/admin --sslCAFile $CERTS_ROOT/certs/ca.pem --ssl --sslPEMKeyFile $CERTS_ROOT/certs/client.pem \
        --eval "rs.initiate( { _id: 'rs', members: [ { _id: 0, host: '$HOSTNAME:27021' }, { _id: 1, host: '$HOSTNAME:27022' }, { _id: 2, host: '$HOSTNAME:27023' }] } )"

    ret=0
    while [[ $ret -eq 0 ]]; do
        ret=$(mongo mongodb://localhost:27021/admin?replicaSet=rs \
            --sslCAFile $CERTS_ROOT/certs/ca.pem --ssl --sslPEMKeyFile $CERTS_ROOT/certs/client.pem \
            --eval 'rs.isMaster()' | grep '"ok" : 1' | wc -l)
        echo "wait for primary..."
        sleep 5
    done

    echo "create admin user"
    mongo mongodb://localhost:27021/admin \
        --sslCAFile $CERTS_ROOT/certs/ca.pem --ssl --sslPEMKeyFile $CERTS_ROOT/certs/client.pem \
        --eval 'db.getSisterDB("$external").runCommand( {
            createUser:"emailAddress=ken.chen@simagix.com,CN=ken.chen,OU=Root,O=Simagix,L=Atlanta,ST=Georgia,C=US" ,
            roles: [{role: "root", db: "admin" }] })'
fi

mongo mongodb://localhost:27021/admin?replicaSet=rs \
    --sslCAFile $CERTS_ROOT/certs/ca.pem --ssl --sslPEMKeyFile $CERTS_ROOT/certs/client.pem \
    --authenticationMechanism MONGODB-X509 --authenticationDatabase "\$external" \
    -u "emailAddress=ken.chen@simagix.com,CN=ken.chen,OU=Root,O=Simagix,L=Atlanta,ST=Georgia,C=US" \
    --eval 'rs.status()'

rm -f mongod.conf
