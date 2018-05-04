#! /bin/bash
export PATH=.:/usr/bin:$PATH
cat /etc/ssl/cluster.keyfile > /tmp/cluster.keyfile
chmod 600 /tmp/cluster.keyfile
mongos -f /etc/mongos.conf 

