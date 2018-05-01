#! /bin/bash

if [ "$1" == "" ]; then
    echo "$1 replset"
    exit
fi

set -m

setname=${HOSTNAME%%-*}
setidx=${HOSTNAME##*-}
replset=$1
primary_host=${setname}-0
primary_port=27017

host=${HOSTNAME}
host=$(hostname -f)
dname=$(echo $host | cut -d'.' -f2-)
primary_host="${primary_host}.${dname}"
port=27017
dbpath="/data/db"
user="admin"
appuser="appuser"
secret="secret"

echo "$setname $setidx $host $port $primary_host $primary_port"

export PATH=.:/usr/bin:$PATH
# sed -i.bak -e "s/port: 27017/port: $port/" -e "s/replSetName: replset/replSetName: $replset/" /etc/mongod.conf
# cat /etc/mongod.template | sed -e "s/port: 27017/port: $port/" -e "s/replSetName: replset/replSetName: $replset/" > /etc/mongod.conf
cat /etc/mongod.conf | sed -e "s/port: 27017/port: $port/" -e "s/replSetName: replset/replSetName: $replset/" > /tmp/mongod.conf
cat /tmp/mongod.conf > /etc/mongod.conf
cat /etc/ssl/cluster.keyfile > /tmp/cluster.keyfile
chmod 600 /tmp/cluster.keyfile
#cat /etc/mongod.conf
MONGOD="mongod -f /etc/mongod.conf"

if [ -z "$(ls -A $dbpath)" ]; then
    $MONGOD &
    ret=1
    while [[ $ret -ne 0 ]]; do
        echo "waiting for mongod..."
        sleep 5
        mongo --port $port --eval "db" >/dev/null 2>&1
        ret=$?
    done
    echo "mongod started..."

    if [ "$host" == "$primary_host" ]; then
        echo "exec rs.initiate()"
        mongo --port $port --eval "rs.initiate( { _id: '$replset', members: [ { _id: 0, host: '$host:$port' } ] } )"
        ret=0
        while [[ $ret -eq 0 ]]; do
            sleep 5
            ret=$(mongo --port $port --eval "rs.isMaster()" | grep '"ismaster" : true' | wc -l)
        done
        mongo --port $port admin --eval "db.createUser({ user: '$user', pwd: '$secret', roles: ['root'] })"
        mongo mongodb://$user:$secret@localhost:$port/admin --eval "db.createUser({ user: '$appuser', pwd: '$secret', roles: [{ role: 'readWriteAnyDatabase', db: 'admin' }] })"
    else
        ret=0
        while [[ $ret -eq 0 ]]; do
            sleep 5
            echo "add $host:$port to replica"
            ret=$(mongo mongodb://$user:$secret@$primary_host:$primary_port/admin --eval "rs.add(\"${host}:${port}\")" | grep '"ok" : 1' | wc -l)
        done
    fi

    fg
else
    exec $MONGOD
fi
