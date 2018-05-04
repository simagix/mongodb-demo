#! /bin/bash
export PATH=.:/usr/bin:$PATH

ret=1
while [[ $ret -ne 0 ]]; do
    echo "waiting for mongos..."
    sleep 5
    mongo mongodb://admin:secret@mongos1/admin --eval 'sh.status()'
    ret=$?
done

sleep 10
mongo mongodb://admin:secret@mongos1/admin --eval 'sh.addShard("shard1/shard1_rs1,shard1_rs2,shard1_rs3")'
mongo mongodb://admin:secret@mongos1/admin --eval 'sh.addShard("shard2/shard2_rs1,shard2_rs2,shard2_rs3")'
#mongo mongodb://admin:secret@mongos1/admin --eval 'sh.addShard("shard1/shard1_rs1")'
#mongo mongodb://admin:secret@mongos1/admin --eval 'sh.addShard("shard2/shard2_rs1")'
mongo mongodb://admin:secret@mongos1/admin --eval 'sh.status()'

