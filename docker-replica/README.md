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


## OpenShift
```
$ kompose --file ../docker-compose.yml --provider openshift up
WARN Restart policy 'unless-stopped' in service repl1 is not supported, convert it to 'always'
WARN Restart policy 'unless-stopped' in service repl2 is not supported, convert it to 'always'
WARN Restart policy 'unless-stopped' in service repl3 is not supported, convert it to 'always'
WARN Volume mount on the host "/Users/kenchen/ws/data/repl1" isn't supported - ignoring path on the host
WARN Volume mount on the host "/Users/kenchen/ws/data/repl2" isn't supported - ignoring path on the host
WARN Volume mount on the host "/Users/kenchen/ws/data/repl3" isn't supported - ignoring path on the host
INFO We are going to create OpenShift DeploymentConfigs, Services and PersistentVolumeClaims for your Dockerized application.
If you need different kind of resources, use the 'kompose convert' and 'oc create -f' commands instead.

INFO Deploying application in "myproject" namespace
INFO Successfully created DeploymentConfig: app1
INFO Successfully created ImageStream: app1
INFO Successfully created DeploymentConfig: repl1
INFO Successfully created ImageStream: repl1
INFO Successfully created PersistentVolumeClaim: repl1-claim0 of size 100Mi. If your cluster has dynamic storage provisioning, you don't have to do anything. Otherwise you have to create PersistentVolume to make PVC work
INFO Successfully created DeploymentConfig: repl2
INFO Successfully created ImageStream: repl2
INFO Successfully created PersistentVolumeClaim: repl2-claim0 of size 100Mi. If your cluster has dynamic storage provisioning, you don't have to do anything. Otherwise you have to create PersistentVolume to make PVC work
INFO Successfully created DeploymentConfig: repl3
INFO Successfully created ImageStream: repl3
INFO Successfully created PersistentVolumeClaim: repl3-claim0 of size 100Mi. If your cluster has dynamic storage provisioning, you don't have to do anything. Otherwise you have to create PersistentVolume to make PVC work

Your application has been deployed to OpenShift. You can run 'oc get dc,svc,is,pvc' for details.
```

### View OC status
```
$ oc get dc,svc,is,pvc
NAME                      REVISION   DESIRED   CURRENT   TRIGGERED BY
deploymentconfigs/app1    0          1         0         config,image(app1:3.6)
deploymentconfigs/repl1   0          1         0         config,image(repl1:3.6)
deploymentconfigs/repl2   0          1         0         config,image(repl2:3.6)
deploymentconfigs/repl3   0          1         0         config,image(repl3:3.6)

NAME                 DOCKER REPO                       TAGS      UPDATED
imagestreams/app1    172.30.1.1:5000/myproject/app1    3.6
imagestreams/repl1   172.30.1.1:5000/myproject/repl1   3.6
imagestreams/repl2   172.30.1.1:5000/myproject/repl2   3.6
imagestreams/repl3   172.30.1.1:5000/myproject/repl3   3.6

NAME               STATUS    VOLUME    CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc/repl1-claim0   Pending                                                     20s
pvc/repl2-claim0   Pending                                                     20s
pvc/repl3-claim0   Pending                                                     20s
```

### OpenShift Push Image
```
oc whoami -t
docker login -u developer -p $(oc whoami -t) 172.30.1.1:5000
for tag in repl1 repl2 repl3 app1
do
    docker rmi 172.30.1.1:5000/myproject/$tag
    docker tag simagix/mongo-repl:3.6 172.30.1.1:5000/myproject/$tag:3.6
    docker push 172.30.1.1:5000/myproject/$tag:3.6
done
```

## Appendix
### Kill Docker
```
docker ps | grep docker | awk '{print $1}' | xargs docker kill
```

### Remove Dangling Images
```
docker images -f "dangling=true" -q  | xargs docker rmi
```

### Outputs of `docker-compose up`
```
$ rm -rf $HOME/ws/data/repl{1,2,3}/*
$ docker-compose up
Creating network "dockerreplica_mongo_net" with driver "bridge"
Creating dockerreplica_app1_1 ...
Creating dockerreplica_repl1_1 ...
Creating dockerreplica_repl3_1 ...
Creating dockerreplica_repl2_1 ...
Creating dockerreplica_repl1_1
Creating dockerreplica_repl3_1
Creating dockerreplica_repl2_1
Creating dockerreplica_repl2_1 ... done
Attaching to dockerreplica_repl1_1, dockerreplica_app1_1, dockerreplica_repl3_1, dockerreplica_repl2_1
repl1_1  | waiting for mongod...
app1_1   | waiting for mongod...
repl3_1  | waiting for mongod...
repl2_1  | waiting for mongod...
repl1_1  | mongod started...
repl1_1  | exec rs.initiate()
repl1_1  | MongoDB shell version v3.6.4
repl1_1  | connecting to: mongodb://127.0.0.1:27017/
repl1_1  | MongoDB server version: 3.6.4
repl1_1  | {
repl1_1  | 	"ok" : 1,
repl1_1  | 	"operationTime" : Timestamp(1524965625, 1),
repl1_1  | 	"$clusterTime" : {
repl1_1  | 		"clusterTime" : Timestamp(1524965625, 1),
repl1_1  | 		"signature" : {
repl1_1  | 			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
repl1_1  | 			"keyId" : NumberLong(0)
repl1_1  | 		}
repl1_1  | 	}
repl1_1  | }
repl3_1  | mongod started...
repl2_1  | mongod started...
app1_1   | waiting for mongod...
repl1_1  | MongoDB shell version v3.6.4
repl1_1  | connecting to: mongodb://127.0.0.1:27017/admin
repl1_1  | MongoDB server version: 3.6.4
repl1_1  | Successfully added user: { "user" : "admin", "roles" : [ "root" ] }
repl1_1  | MongoDB shell version v3.6.4
repl1_1  | connecting to: mongodb://localhost:27017/admin
repl1_1  | MongoDB server version: 3.6.4
repl1_1  | Successfully added user: {
repl1_1  | 	"user" : "appuser",
repl1_1  | 	"roles" : [
repl1_1  | 		{
repl1_1  | 			"role" : "readWriteAnyDatabase",
repl1_1  | 			"db" : "admin"
repl1_1  | 		}
repl1_1  | 	]
repl1_1  | }
repl3_1  | add 172.16.0.10:27017 to replica
repl1_1  | $MONGOD
repl3_1  | $MONGOD
repl2_1  | add 172.16.0.9:27017 to replica
repl2_1  | $MONGOD
app1_1   | MongoDB shell version v3.6.4
app1_1   | connecting to: mongodb://repl1:27017,repl2:27017,repl3:27017/test?authSource=admin&replicaSet=rs1
app1_1   | 2018-04-29T01:33:52.755+0000 I NETWORK  [thread1] Starting new replica set monitor for rs1/repl1:27017,repl2:27017,repl3:27017
app1_1   | 2018-04-29T01:33:52.759+0000 I NETWORK  [thread1] Successfully connected to repl1:27017 (1 connections now open to repl1:27017 with a 5 second timeout)
app1_1   | 2018-04-29T01:33:52.759+0000 I NETWORK  [ReplicaSetMonitor-TaskExecutor-0] Successfully connected to repl3:27017 (1 connections now open to repl3:27017 with a 5 second timeout)
app1_1   | 2018-04-29T01:33:52.760+0000 I NETWORK  [thread1] changing hosts to rs1/172.16.0.10:27017,172.16.0.8:27017,172.16.0.9:27017 from rs1/repl1:27017,repl2:27017,repl3:27017
app1_1   | 2018-04-29T01:33:52.762+0000 I NETWORK  [ReplicaSetMonitor-TaskExecutor-0] Successfully connected to 172.16.0.8:27017 (1 connections now open to 172.16.0.8:27017 with a 5 second timeout)
app1_1   | 2018-04-29T01:33:52.762+0000 I NETWORK  [thread1] Successfully connected to 172.16.0.10:27017 (1 connections now open to 172.16.0.10:27017 with a 5 second timeout)
app1_1   | 2018-04-29T01:33:52.764+0000 I NETWORK  [thread1] Successfully connected to 172.16.0.9:27017 (1 connections now open to 172.16.0.9:27017 with a 5 second timeout)
app1_1   | MongoDB server version: 3.6.4
app1_1   | {
app1_1   | 	"set" : "rs1",
app1_1   | 	"date" : ISODate("2018-04-29T01:33:52.788Z"),
app1_1   | 	"myState" : 1,
app1_1   | 	"term" : NumberLong(1),
app1_1   | 	"heartbeatIntervalMillis" : NumberLong(2000),
app1_1   | 	"optimes" : {
app1_1   | 		"lastCommittedOpTime" : {
app1_1   | 			"ts" : Timestamp(1524965631, 1),
app1_1   | 			"t" : NumberLong(1)
app1_1   | 		},
app1_1   | 		"readConcernMajorityOpTime" : {
app1_1   | 			"ts" : Timestamp(1524965631, 1),
app1_1   | 			"t" : NumberLong(1)
app1_1   | 		},
app1_1   | 		"appliedOpTime" : {
app1_1   | 			"ts" : Timestamp(1524965631, 1),
app1_1   | 			"t" : NumberLong(1)
app1_1   | 		},
app1_1   | 		"durableOpTime" : {
app1_1   | 			"ts" : Timestamp(1524965631, 1),
app1_1   | 			"t" : NumberLong(1)
app1_1   | 		}
app1_1   | 	},
app1_1   | 	"members" : [
app1_1   | 		{
app1_1   | 			"_id" : 0,
app1_1   | 			"name" : "172.16.0.8:27017",
app1_1   | 			"health" : 1,
app1_1   | 			"state" : 1,
app1_1   | 			"stateStr" : "PRIMARY",
app1_1   | 			"uptime" : 12,
app1_1   | 			"optime" : {
app1_1   | 				"ts" : Timestamp(1524965631, 1),
app1_1   | 				"t" : NumberLong(1)
app1_1   | 			},
app1_1   | 			"optimeDate" : ISODate("2018-04-29T01:33:51Z"),
app1_1   | 			"infoMessage" : "could not find member to sync from",
app1_1   | 			"electionTime" : Timestamp(1524965625, 2),
app1_1   | 			"electionDate" : ISODate("2018-04-29T01:33:45Z"),
app1_1   | 			"configVersion" : 3,
app1_1   | 			"self" : true
app1_1   | 		},
app1_1   | 		{
app1_1   | 			"_id" : 1,
app1_1   | 			"name" : "172.16.0.10:27017",
app1_1   | 			"health" : 1,
app1_1   | 			"state" : 2,
app1_1   | 			"stateStr" : "SECONDARY",
app1_1   | 			"uptime" : 1,
app1_1   | 			"optime" : {
app1_1   | 				"ts" : Timestamp(1524965630, 5),
app1_1   | 				"t" : NumberLong(1)
app1_1   | 			},
app1_1   | 			"optimeDurable" : {
app1_1   | 				"ts" : Timestamp(1524965630, 5),
app1_1   | 				"t" : NumberLong(1)
app1_1   | 			},
app1_1   | 			"optimeDate" : ISODate("2018-04-29T01:33:50Z"),
app1_1   | 			"optimeDurableDate" : ISODate("2018-04-29T01:33:50Z"),
app1_1   | 			"lastHeartbeat" : ISODate("2018-04-29T01:33:51.615Z"),
app1_1   | 			"lastHeartbeatRecv" : ISODate("2018-04-29T01:33:52.141Z"),
app1_1   | 			"pingMs" : NumberLong(0),
app1_1   | 			"configVersion" : 2
app1_1   | 		},
app1_1   | 		{
app1_1   | 			"_id" : 2,
app1_1   | 			"name" : "172.16.0.9:27017",
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
app1_1   | 			"lastHeartbeat" : ISODate("2018-04-29T01:33:51.618Z"),
app1_1   | 			"lastHeartbeatRecv" : ISODate("2018-04-29T01:33:52.187Z"),
app1_1   | 			"pingMs" : NumberLong(1),
app1_1   | 			"configVersion" : -2
app1_1   | 		}
app1_1   | 	],
app1_1   | 	"ok" : 1,
app1_1   | 	"operationTime" : Timestamp(1524965631, 1),
app1_1   | 	"$clusterTime" : {
app1_1   | 		"clusterTime" : Timestamp(1524965631, 1),
app1_1   | 		"signature" : {
app1_1   | 			"hash" : BinData(0,"iv3EFKH36JRasfEjLNlm0XctZiU="),
app1_1   | 			"keyId" : NumberLong("6549677495489134593")
app1_1   | 		}
app1_1   | 	}
app1_1   | }
dockerreplica_app1_1 exited with code 0
```
