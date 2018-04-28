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

