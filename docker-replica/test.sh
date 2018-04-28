#! /bin/bash

mongo_url=$1

export PATH=.:/usr/bin:$PATH

ret=1
while [[ $ret -ne 0 ]]; do
    echo "waiting for mongod..."
    sleep 5
    mongo $1 --eval "db" >/dev/null 2>&1
    ret=$?
done
mongo $1 --eval "rs.status()"
