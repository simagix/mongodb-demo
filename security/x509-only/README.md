# X.509 Certificates
The purpose of this demo is to secure a MongoDB replica set using only X.509 certificates.  In this example, we use X.509 certificate for

- Client authentication
- Cluster authorization

All cerrtificates have to be in place

- /etc/ssl/certs/car.crt
- /etc/ssl/certs/server.pem
- /etc/ssl/certs/client.pem

Script `create_replica.sh` does

- Spin up 3 instances of `mongod`
- Initiate a replica set
- Create a use defined in a certificate.

Example *mongod.conf* file

```
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
storage:
  dbPath: /data/rs1/db
  journal:
    enabled: true
processManagement:
  fork: true
  pidFilePath: /var/run/mongodb/mongod-27020.pid
net:
  port: 27020
  bindIp: 0.0.0.0
  ssl:
    mode: requireSSL
    PEMKeyFile: /etc/ssl/certs/server.pem
    clusterFile: /etc/ssl/certs/server.pem
    CAFile: /etc/ssl/certs/ca.pem
replication:
  replSetName: rs
security:
  authorization: enabled
  clusterAuthMode: x509
```
