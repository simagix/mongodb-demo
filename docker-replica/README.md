
# Docker Replica
Use `/entrypoint.sh` to boostrap a MongoDB replica set.

## Build Docker Image
```
docker build . -t simagix/mongo:3.6.3
```

## /etc/hosts
```
192.168.0.123   repl1 repl2 repl3
```

## Run Docker
```
#rm -rf $HOME/ws/data/repl{1,2,3}
mkdir -p $HOME/ws/data/repl{1,2,3}
docker run -h repl1 -p 30001:30001 -v $HOME/ws/data/repl1:/data/db/ simagix/mongo:3.6.3 /entrypoint.sh replset repl1 30001 repl1 30001 &
docker run -h repl2 -p 30002:30002 -v $HOME/ws/data/repl2:/data/db/ simagix/mongo:3.6.3 /entrypoint.sh replset repl2 30002 repl1 30001 &
docker run -h repl3 -p 30003:30003 -v $HOME/ws/data/repl3:/data/db/ simagix/mongo:3.6.3 /entrypoint.sh replset repl3 30003 repl1 30001 &
```

## Kill Docker
```
docker ps | grep docker | awk '{print $1}' | xargs docker kill
```

