#! /bin/bash

if [ "$5" == "" ]; then
    echo "$0 replica host port primary_host primary_port [dbpath]"
    echo "./bootstrap.sh dev localhost 27017 localhost 27017"
    exit
fi

set -m
replset="$1"
host="$2"
port=$3
primary_host="$4"
primary_port=$5
dbpath="/data/db"

if [ "$6" != "" ]; then
    dbpath="$6"
    rm -rf $dbpath/*
fi

export PATH=.:/usr/bin:$PATH:/usr/local/m/current/bin
MONGOD="mongod --bind_ip_all --port $port --dbpath $dbpath --logpath $dbpath/mongod.log --replSet $replset"

if [ -z "$(ls -A $dbpath)" ]; then
    $MONGOD &
    ret=1
    while [[ $ret -ne 0 ]]; do
        sleep 2
        mongo --port $port --eval "db" >/dev/null 2>&1
        ret=$?
    done

    if [ "$host" == "$primary_host" ]; then
        mongo --port $port --eval "rs.initiate()"
    else
        ret=0
        while [[ $ret -eq 0 ]]; do
            sleep 2
            ret=$(mongo mongodb://$primary_host:$primary_port/admin --eval "rs.add(\"${host}:${port}\")" | grep '"ok" : 1' | wc -l)
        done
    fi

    fg
else
    exec $MONGOD
fi
