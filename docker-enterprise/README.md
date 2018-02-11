# Build MongoDB Enterprise 3.6 Docker Container

## To Build
```
docker build . -t simagix/mongo:3.6.2-ent
```

## To Run
```
docker run -i -p 27017:27017 -t simagix/mongo:3.6.2-ent

docker run -i -p 27017:27017 -t simagix/mongo:3.6.2-ent mongod --bind_ip_all

docker run -i -p 27017:27017 -v $(pwd)/certs/:/etc/ssl/ -t simagix/mongo:3.6.2-ent mongod --bind_ip_all --auth --sslMode requireSSL --sslCAFile /etc/ssl/ca.crt --sslPEMKeyFile /etc/ssl/server.pem --sslFIPSMode
```

## Cluster Keyfile
```
openssl rand -base64 756 > cluster.keyfile
```

## Encryption At Rest Keyfile
```
openssl rand -base64 32 > at-rest.keyfile
```
