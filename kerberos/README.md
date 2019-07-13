# Kerberos and MongoDB Enterprise Integration
Demo how MongoDB Enterprise server integrates with Kerberos 5 server.

## build
```
docker build -t simagix/kerberos -f Dockerfile-krb .
docker build -t simagix/mongo-kerberos -f Dockerfile-mdb .
```

## Run
```
docker-compose up
```

## Shutdown
```
docker-compose down
```
