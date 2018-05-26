# At-Rest Encryption using KMIP
## PyKMIP Server
### Install PyKMIP
```
virtualenv ws
source ws/bin/activate
pip install pykmip requests
```

### `/etc/pykmip/server.conf`
```
[server]
hostname=127.0.0.1
port=5696
certificate_path=/etc/ssl/certs/server.pem
key_path=/etc/ssl/certs/server.pem
ca_path=/etc/ssl/certs/ca.pem
auth_suite=Basic
policy_path=/etc/pykmip/policies
```

### Start PyKMIP Server
```
pykmip-server
```

## MongoDB
### Start `mongod`
```
mongod --dbpath ~/ws/pykmip/ --enableEncryption \
    --kmipServerName localhost --kmipServerCAFile /etc/ssl/certs/ca.pem \
    --kmipClientCertificateFile /etc/ssl/certs/client.pem
```

#### `mongod.conf`
```
systemLog:
  destination: file
  logAppend: true
  path: /tmp/mongod.log
storage:
  dbPath: ws/pykmip
  journal:
    enabled: true
  wiredTiger:
    engineConfig:
      cacheSizeGB: 1
processManagement:
  fork: true
  pidFilePath: /tmp/mongod-27017.pid
net:
  port: 27017
  bindIp: 127.0.0.1
security:
  enableEncryption: true
  kmip:
    serverName: localhost
    clientCertificateFile: /etc/ssl/certs/client.pem
    serverCAFile: /etc/ssl/certs/ca.pem
#    rotateMasterKey: true
```

### Rotate Master Key
```
mongod --dbpath ~/ws/pykmip/ --enableEncryption \
    --kmipServerName localhost --kmipServerCAFile /etc/ssl/certs/ca.pem \
    --kmipClientCertificateFile /etc/ssl/certs/client.pem \
    --kmipRotateMasterKey
```

Or set *security.kmip.rotateMasterKey* to **true**.

```
security:
  kmip:
    rotateMasterKey: true
```