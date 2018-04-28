# Docker Replica
Use `/entrypoint.sh` to boostrap a MongoDB replica set.

## Build Docker Image
```
docker build . -t simagix/mongo-repl:3.6
```

## Run Docker - docker-compose
```
#rm -rf $HOME/ws/data/repl{1,2,3}/*
mkdir -p $HOME/ws/data/repl{1,2,3}
docker-compose up &
```

See sample output in docker-compose output below.

## Run Docker
```
docker run -h repl1 -p 27017:27017 -v /data/repl1/db/:/data/db/ simagix/mongo-repl:3.6 /entrypoint.sh replset repl1 27017 &
docker run -h repl2 -p 27017:27017 -v /data/repl2/db/:/data/db/ simagix/mongo-repl:3.6 /entrypoint.sh replset repl1 27017 &
docker run -h repl3 -p 27017:27017 -v /data/repl3/db/:/data/db/ simagix/mongo-repl:3.6 /entrypoint.sh replset repl1 27017 &
```

## Run Docker - Test
### /etc/hosts
```
192.168.0.123   repl1 repl2 repl3
```

### Command
```
#rm -rf $HOME/ws/data/repl{1,2,3}/*
mkdir -p $HOME/ws/data/repl{1,2,3}
docker run -h repl1 -p 30001:30001 -v $HOME/ws/data/repl1:/data/db/ simagix/mongo-repl:3.6 /entrypoint.sh replset repl1 30001 30001 &
docker run -h repl2 -p 30002:30002 -v $HOME/ws/data/repl2:/data/db/ simagix/mongo-repl:3.6 /entrypoint.sh replset repl1 30001 30002 &
docker run -h repl3 -p 30003:30003 -v $HOME/ws/data/repl3:/data/db/ simagix/mongo-repl:3.6 /entrypoint.sh replset repl1 30001 30003 &
```

### Kill Docker
```
docker ps | grep docker | awk '{print $1}' | xargs docker kill
```

### Remove Dangling Images
```
docker images -f "dangling=true" -q  | xargs docker rmi
```

## Appendix
### Outputs of `docker-compose up`
```
$ rm -rf $HOME/ws/data/repl{1,2,3}/*
$ docker-compose up
Creating network "docker-replica_mongo_net" with driver "bridge"
Creating docker-replica_repl1_1 ... done
Creating docker-replica_repl2_1 ... done
Creating docker-replica_repl3_1 ... done
Creating docker-replica_app1_1  ... done
Attaching to docker-replica_repl1_1, docker-replica_app1_1, docker-replica_repl3_1, docker-replica_repl2_1
repl1_1  | waiting for mongod...
app1_1   | waiting for mongod...
repl2_1  | waiting for mongod...
repl3_1  | waiting for mongod...
repl1_1  | mongod started...
repl1_1  | exec rs.initiate()
repl1_1  | MongoDB shell version v3.6.3
repl1_1  | connecting to: mongodb://127.0.0.1:27017/
repl1_1  | MongoDB server version: 3.6.3
repl1_1  | {
repl1_1  | 	"ok" : 1,
repl1_1  | 	"operationTime" : Timestamp(1524921512, 1),
repl1_1  | 	"$clusterTime" : {
repl1_1  | 		"clusterTime" : Timestamp(1524921512, 1),
repl1_1  | 		"signature" : {
repl1_1  | 			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
repl1_1  | 			"keyId" : NumberLong(0)
repl1_1  | 		}
repl1_1  | 	}
repl1_1  | }
repl3_1  | mongod started...
repl2_1  | mongod started...
app1_1   | waiting for mongod...
repl1_1  | MongoDB shell version v3.6.3
repl3_1  | add repl3:27017 to replica
repl1_1  | connecting to: mongodb://127.0.0.1:27017/admin
repl1_1  | MongoDB server version: 3.6.3
repl1_1  | Successfully added user: { "user" : "admin", "roles" : [ "root" ] }
repl1_1  | MongoDB shell version v3.6.3
repl3_1  | $MONGOD
repl1_1  | connecting to: mongodb://localhost:27017/admin
repl1_1  | MongoDB server version: 3.6.3
repl2_1  | add repl2:27017 to replica
repl1_1  | Successfully added user: {
repl1_1  | 	"user" : "appuser",
repl1_1  | 	"roles" : [
repl1_1  | 		{
repl1_1  | 			"role" : "readWriteAnyDatabase",
repl1_1  | 			"db" : "admin"
repl1_1  | 		}
repl1_1  | 	]
repl1_1  | }
repl2_1  | $MONGOD
repl1_1  | $MONGOD
app1_1   | MongoDB shell version v3.6.3
app1_1   | connecting to: mongodb://repl1:27017,repl2:27017,repl3:27017/test?authSource=admin&replicaSet=replset
app1_1   | 2018-04-28T13:18:39.954+0000 I NETWORK  [thread1] Starting new replica set monitor for replset/repl1:27017,repl2:27017,repl3:27017
app1_1   | 2018-04-28T13:18:39.958+0000 I NETWORK  [thread1] Successfully connected to repl3:27017 (1 connections now open to repl3:27017 with a 5 second timeout)
app1_1   | 2018-04-28T13:18:39.958+0000 I NETWORK  [ReplicaSetMonitor-TaskExecutor-0] Successfully connected to repl2:27017 (1 connections now open to repl2:27017 with a 5 second timeout)
app1_1   | 2018-04-28T13:18:39.959+0000 I NETWORK  [thread1] Successfully connected to repl1:27017 (1 connections now open to repl1:27017 with a 5 second timeout)
app1_1   | MongoDB server version: 3.6.3
app1_1   | {
app1_1   | 	"set" : "replset",
app1_1   | 	"date" : ISODate("2018-04-28T13:18:39.977Z"),
app1_1   | 	"myState" : 1,
app1_1   | 	"term" : NumberLong(1),
app1_1   | 	"heartbeatIntervalMillis" : NumberLong(2000),
app1_1   | 	"optimes" : {
app1_1   | 		"lastCommittedOpTime" : {
app1_1   | 			"ts" : Timestamp(1524921518, 2),
app1_1   | 			"t" : NumberLong(1)
app1_1   | 		},
app1_1   | 		"readConcernMajorityOpTime" : {
app1_1   | 			"ts" : Timestamp(1524921518, 2),
app1_1   | 			"t" : NumberLong(1)
app1_1   | 		},
app1_1   | 		"appliedOpTime" : {
app1_1   | 			"ts" : Timestamp(1524921518, 2),
app1_1   | 			"t" : NumberLong(1)
app1_1   | 		},
app1_1   | 		"durableOpTime" : {
app1_1   | 			"ts" : Timestamp(1524921518, 2),
app1_1   | 			"t" : NumberLong(1)
app1_1   | 		}
app1_1   | 	},
app1_1   | 	"members" : [
app1_1   | 		{
app1_1   | 			"_id" : 0,
app1_1   | 			"name" : "repl1:27017",
app1_1   | 			"health" : 1,
app1_1   | 			"state" : 1,
app1_1   | 			"stateStr" : "PRIMARY",
app1_1   | 			"uptime" : 12,
app1_1   | 			"optime" : {
app1_1   | 				"ts" : Timestamp(1524921518, 2),
app1_1   | 				"t" : NumberLong(1)
app1_1   | 			},
app1_1   | 			"optimeDate" : ISODate("2018-04-28T13:18:38Z"),
app1_1   | 			"infoMessage" : "could not find member to sync from",
app1_1   | 			"electionTime" : Timestamp(1524921512, 2),
app1_1   | 			"electionDate" : ISODate("2018-04-28T13:18:32Z"),
app1_1   | 			"configVersion" : 3,
app1_1   | 			"self" : true
app1_1   | 		},
app1_1   | 		{
app1_1   | 			"_id" : 1,
app1_1   | 			"name" : "repl3:27017",
app1_1   | 			"health" : 1,
app1_1   | 			"state" : 2,
app1_1   | 			"stateStr" : "SECONDARY",
app1_1   | 			"uptime" : 2,
app1_1   | 			"optime" : {
app1_1   | 				"ts" : Timestamp(1524921518, 1),
app1_1   | 				"t" : NumberLong(1)
app1_1   | 			},
app1_1   | 			"optimeDurable" : {
app1_1   | 				"ts" : Timestamp(1524921518, 1),
app1_1   | 				"t" : NumberLong(1)
app1_1   | 			},
app1_1   | 			"optimeDate" : ISODate("2018-04-28T13:18:38Z"),
app1_1   | 			"optimeDurableDate" : ISODate("2018-04-28T13:18:38Z"),
app1_1   | 			"lastHeartbeat" : ISODate("2018-04-28T13:18:38.840Z"),
app1_1   | 			"lastHeartbeatRecv" : ISODate("2018-04-28T13:18:38.863Z"),
app1_1   | 			"pingMs" : NumberLong(0),
app1_1   | 			"configVersion" : 2
app1_1   | 		},
app1_1   | 		{
app1_1   | 			"_id" : 2,
app1_1   | 			"name" : "repl2:27017",
app1_1   | 			"health" : 1,
app1_1   | 			"state" : 0,
app1_1   | 			"stateStr" : "STARTUP",
app1_1   | 			"uptime" : 1,
app1_1   | 			"optime" : {
app1_1   | 				"ts" : Timestamp(0, 0),
app1_1   | 				"t" : NumberLong(-1)
app1_1   | 			},
app1_1   | 			"optimeDurable" : {
app1_1   | 				"ts" : Timestamp(0, 0),
app1_1   | 				"t" : NumberLong(-1)
app1_1   | 			},
app1_1   | 			"optimeDate" : ISODate("1970-01-01T00:00:00Z"),
app1_1   | 			"optimeDurableDate" : ISODate("1970-01-01T00:00:00Z"),
app1_1   | 			"lastHeartbeat" : ISODate("2018-04-28T13:18:38.848Z"),
app1_1   | 			"lastHeartbeatRecv" : ISODate("2018-04-28T13:18:38.894Z"),
app1_1   | 			"pingMs" : NumberLong(1),
app1_1   | 			"configVersion" : -2
app1_1   | 		}
app1_1   | 	],
app1_1   | 	"ok" : 1,
app1_1   | 	"operationTime" : Timestamp(1524921518, 2),
app1_1   | 	"$clusterTime" : {
app1_1   | 		"clusterTime" : Timestamp(1524921518, 2),
app1_1   | 		"signature" : {
app1_1   | 			"hash" : BinData(0,"9nyMdmaHhFNGrXdLlNNgX3pBSXk="),
app1_1   | 			"keyId" : NumberLong("6549488031596806145")
app1_1   | 		}
app1_1   | 	}
app1_1   | }
docker-replica_app1_1 exited with code 0
```
