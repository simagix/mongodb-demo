# Docker Replica
Create MongoDB sharded cluster in Docker

## Build Docker Image
```
docker build . -t simagix/mongo-shard:3.6
```

## Run Docker - docker-compose
```
#rm -rf $HOME/ws/data/shard{1,2}/rs{1,2,3}/* $HOME/ws/data/cfg/rs{1,2,3}/*
mkdir -p $HOME/ws/data/shard{1,2}/rs{1,2,3} $HOME/ws/data/cfg/rs{1,2,3}
docker-compose up
```

## Steps
- Start a replica of config servers
  - rs.initiate()
  - db.createUser()
  - rs.add() 
- Start 2 shards of replica
  - rs.initiate()
  - db.createUser()
  - rs.add() 
- Start a mongos
- Add shards
  - sh.addShard()

