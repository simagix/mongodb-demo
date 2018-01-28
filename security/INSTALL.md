# MongoDB Installation and Configurations

Instructions to install and secure MongoDB 3.6 on CentOS or RHEL 7 on AWS.

- Turn off SELinux
- Turn off Transparent Huge Pages
- Install a replica set on CentOS 7
- Increase nproc and nofile of ulimit
- Data at rest encryption
- Create first admin user
- Create application user, access control
- Enable authentication
- Transport encryption
- Java example
- Sample /etc/mongod.conf
- Files

## Disable SELinux
```
sudo vi /etc/selinux/config
```

Modify the value of *SELINUX* to

```
SELINUX=disabled
```

## Disable Transparent Huge Pages
To permanently [disable THP](https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/), create the following file at */etc/init.d/disable-transparent-hugepages*:

[^disable THP]: https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/

```
#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case $1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > ${thp_path}/enabled
    echo 'never' > ${thp_path}/defrag

    re='^[0-1]+$'
    if [[ $(cat ${thp_path}/khugepaged/defrag) =~ $re ]]
    then
      # RHEL 7
      echo 0  > ${thp_path}/khugepaged/defrag
    else
      # RHEL 6
      echo 'no' > ${thp_path}/khugepaged/defrag
    fi

    unset re
    unset thp_path
    ;;
esac
```

Make the file exectable.

```
sudo chmod +x /etc/init.d/disable-transparent-hugepages
sudo chkconfig --add disable-transparent-hugepages
```
Or disable THP one time.

```
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
```

## Install MongoDB
### Database Path
Create a database volume and mount it at /data by following [Production Notes](https://docs.mongodb.com/manual/administration/production-notes/)

[^Production Notes]: https://docs.mongodb.com/manual/administration/production-notes/

### Installation
Follow [Install MongoDB Enterprise on Red Hat Enterprise or CentOS](https://docs.mongodb.com/manual/tutorial/install-mongodb-enterprise-on-red-hat/) to install latest version of MongoDB 3.6.  First, create yum repo for MongoDB 3.6 Enterprise edition.

[^Install MongoDB Enterprise]: https://docs.mongodb.com/manual/tutorial/install-mongodb-enterprise-on-red-hat/

```
sudo vi /etc/yum.repos.d/mongodb-enterprise.repo
```

Add the lines below to */etc/yum.repos.d/mongodb-enterprise.repo*

```
[mongodb-enterprise]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/3.6/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc
```

Install MongoDB Enterprise edition.

```
sudo yum install -y mongodb-enterprise
```

### Update Database Path
```
sudo mkdir /data/db
sudo chown mongod:mongod /data/db
sudo cp /etc/mongod.conf /etc/mongod.conf.orig
sudo vi /etc/mongod.conf
```

Modify `storage.dbPath` to

```
storage:
  dbPath: /data/db
```

### Increase nproc and nofile of ulimit
[Unix ulimit Settings](https://docs.mongodb.com/manual/reference/ulimit/)

[^Unix ulimit Settings]: https://docs.mongodb.com/manual/reference/ulimit/

```
sudo vi /etc/security/limits.d/20-nproc.conf
```

Add *nproc* and *nofile* limits for *mongod* user.

```
mongod     soft    nproc     64000
mongod     hard    nproc     64000
mongod     soft    nofile     64000
mongod     hard    nofile     64000
```

## Encryption at Rest
[Encryption at Rest](https://docs.mongodb.com/manual/core/security-encryption-at-rest/) includes the following steps:

[^Encryption at Rest]: https://docs.mongodb.com/manual/core/security-encryption-at-rest/

- Generating a master key.
- Generating keys for each database.
- Encrypting data with the database keys.
- Encrypting the database keys with the master key.

```
sudo mkdir -p /etc/ssl
sudo chown $USER:$USER /etc/ssl
openssl rand -base64 32 > /etc/ssl/enc-keyfile
chmod 600 /etc/ssl/enc-keyfile
```

```
security:
  enableEncryption: true
  encryptionKeyFile: /etc/ssl/enc-keyfile
```

## Start MongoDB Server
Enable `mongod` server startup service

```
sudo chkconfig mongod on
```

Reboot the instance to make changes on SELinux, THP, and ulimit to take effect and starts `mongod`.

## Deploy a Replica Set
- [Deploy a Replica Set](https://docs.mongodb.com/manual/tutorial/deploy-replica-set/)
- [Deploy New Replica Set With Keyfile Access Control](https://docs.mongodb.com/manual/tutorial/deploy-replica-set-with-keyfile-access-control/#deploy-repl-set-with-auth)

[^Deploy a Replica Set]: https://docs.mongodb.com/manual/tutorial/deploy-replica-set/
[^Deploy New Replica Set With Keyfile Access Control]: https://docs.mongodb.com/manual/tutorial/deploy-replica-set-with-keyfile-access-control/#deploy-repl-set-with-auth/

### Create Keyfile
```
openssl rand -base64 756 > /tmp/rs0-dev.keyfile
sudo cp /tmp/rs0-dev.keyfile /etc/ssl/
sudo chown mongod:mongod /etc/ssl/rs0-dev.keyfile
sudo chmod 400 /etc/ssl/rs0-dev.keyfile
```

Copy the key file to the other replica members and update `/etc/mongod.conf`.

```
sudo vi /etc/mongod.conf
```

Add replication and security to `/etc/mongod.conf` file.
  
```
replication:
  replSetName: "rs-dev"
net:
  bindIp: localhost,<ip address>
security:
  keyFile: /etc/ssl/rs0-dev.keyfile
```

Restart `mongod` 

```
sudo service mongod restart
```

### Initiate replica

```
/usr/bin/mongo mongodb://ip-172-31-1-1.ec2.internal
rs.initiate()
rs.add("ip-172-31-2-2.ec2.internal")
rs.add("ip-172-31-3-3.ec2.internal")
```

Test connection.

```
/usr/bin/mongo mongodb://ip-172-31-1-1.ec2.internal,ip-172-31-2-2.ec2.internal,ip-172-31-3-3.ec2.internal/admin
```

## Enable Authentication
- [Security Checklist](https://docs.mongodb.com/manual/administration/security-checklist/)
- [Enable Auth](https://docs.mongodb.com/manual/tutorial/enable-authentication/)

[^Security Checklist]: https://docs.mongodb.com/manual/administration/security-checklist/
[^Enable Auth]: https://docs.mongodb.com/manual/tutorial/enable-authentication/

### Create First Admin User.

```
use admin
db.createUser(
  {
    user: "mongoadm",
    pwd: "secret",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
```

Grant additional roles.

```
db.grantRolesToUser('mongoadm', ['clusterAdmin', 'readWriteAnyDatabase', 'dbAdminAnyDatabase'])
```

Or, a shortcut.

```
db.getSisterDB('admin').createUser(
  {
    user: "mongoadm",
    pwd: "secret",
    roles: [ 'userAdminAnyDatabase', 'clusterAdmin', 'readWriteAnyDatabase', 'dbAdminAnyDatabase']
  }
)
```

Enable authorization.

```
sudo vi /etc/mongod.conf
```

```
security:
  authorization: enabled
```

Restart `mongod` and test connection.

```
sudo service mongod restart
/usr/bin/mongo mongodb://mongoadm:secret@ip-172-31-1-1.ec2.internal,ip-172-31-2-2.ec2.internal,ip-172-31-3-3.ec2.internal/test?authSource=admin
```

### Manage Users and Roles
[Manage Users and Roles](https://docs.mongodb.com/manual/tutorial/manage-users-and-roles/)

[^Manage Users and Roles]: https://docs.mongodb.com/manual/tutorial/manage-users-and-roles/
Create an *super* application user.

```
db.createUser(
  {
    user: "appuser",
    pwd: "secret",
    roles: [ { role: "readWriteAnyDatabase", db: "admin" } ]
  }
)
```

Create a user with limited access.

```
db.createUser(
  {
    user: "loguser",
    pwd: "secret",
    roles: [ { role: "readWrite", db: "log" } ]
  }
)
```

## Transport Encryption
- [Encryption](https://docs.mongodb.com/manual/core/security-encryption/)
- [Transport Encryption](https://docs.mongodb.com/manual/core/security-transport-encryption/)
- [Configure mongod and mongos for TLS/SSL](https://docs.mongodb.com/manual/tutorial/configure-ssl/)
- [TLS/SSL Configuration for Clients](https://docs.mongodb.com/manual/tutorial/configure-ssl-clients/)

[^Encryption]: https://docs.mongodb.com/manual/core/security-encryption/
[^Transport Encryption]: https://docs.mongodb.com/manual/core/security-transport-encryption/
[^Configure mongod and mongos for TLS/SSL]: https://docs.mongodb.com/manual/tutorial/configure-ssl/
[^TLS/SSL Configuration for Clients]: https://docs.mongodb.com/manual/tutorial/configure-ssl-clients/


### Certificates Creation

Create X509 certificate and key files.  Download [create_certs.sh](https://github.com/simagix/mongodb-utils/blob/master/certificates/create_certs.sh) to `/tmp/` and add all hostnames in.

```
#! /bin/bash
#
# author: Ken Chen
# create certificates with alternative names
#
PWD=$(pwd)
if [ "$1" = "" ]; then
    TMP=$PWD
else
    TMP=$1
fi

mkdir -p $TMP/certs
cd $TMP/certs
echo "Files are created in $TMP/certs"

read -r -d '' DN <<-EOF
C=US
ST=Georgia
L=Atlanta
O=Simagix
OU=DEV
CN=localhost
emailAddress=ken.chen@simagix.com
EOF

read -r -d '' CADATA <<-EOF
[req]
default_bits = 2048
prompt = no
distinguished_name = dn
default_md = x509
x509_extensions = v3_req
[dn]
$DN
[v3_req]
subjectAltName = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:TRUE

[alt_names]
DNS.1=localhost
IP.1=127.0.0.1
EOF

read -r -d '' PEMDATA <<-EOF
[req]
default_bits = 2048
prompt = no
distinguished_name = dn
default_md = x509
req_extensions = v3_req
[dn]
$DN
[v3_req]
EOF

# CA certificates
# echo "Creating server certificate and key file: ca.crt and ca.key"
openssl req -nodes -x509 -days 365 -newkey rsa:2048 -keyout ca.key -out ca.crt -config <(
cat <<-EOF
$CADATA
EOF
)

# Server certificates
openssl req -nodes -newkey rsa:2048 -keyout server.key -out server.csr -config <(
cat <<-EOF
$PEMDATA
EOF
)

openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 365 -out server.crt -extfile <(
cat <<-EOF
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1=localhost
DNS.2 = ip-172-31-1-1.ec2.internal
DNS.3 = ip-172-31-2-2.ec2.internal
DNS.4 = ip-172-31-3-3.ec2.internal
DNS.5 = ec2-52-91-1-1.compute-1.amazonaws.com 
DNS.6 = ec2-54-210-2-2.compute-1.amazonaws.com 
DNS.7 = ec2-54-157-3-3.compute-1.amazonaws.com 
EOF
)
cat server.key server.crt > server.pem

# Client certificates
# echo "Creating client certificate and key file: client.crt and client.key"
openssl req -nodes -newkey rsa:2048 -keyout client.key -out client.csr -config <(
cat <<-EOF
$PEMDATA
EOF
)
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAserial ca.srl -days 365 -out client.crt -extfile <(
cat <<-EOF
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
EOF
)
cat client.key client.crt > client.pem

ls -l $TMP/certs/ca.crt $TMP/certs/server.pem $TMP/certs/client.pem
cd $PWD
```

### Create server.pem and ca.crt
Create `ca.crt`, `server.pem`, and `client.pem` files and install them under /etc/ssl.

```
cd /tmp/
/tmp/create_certs.sh
mv -f /tmp/certs/ca.crt /etc/ssl/
mv -f /tmp/certs/server.pem /etc/ssl/
mv -f /tmp/certs/client.pem /etc/ssl/
```

To view certificates contents.

```
openssl x509 -in /etc/ssl/server.pem -text -noout
openssl x509 -in /etc/ssl/ca.crt -text -noout
```

### Enable encryption

```
sudo vi /etc/mongod.conf
```

```
net:
  ssl:
    mode: allowSSL
    PEMKeyFile: /etc/ssl/server.pem
    CAFile: /etc/ssl/ca.crt
```

### Upgrade a Cluster to TLS/SSL
After completing instructions from [Upgrade a Cluster to user TLS/SSL](https://docs.mongodb.com/manual/tutorial/upgrade-cluster-to-ssl/), restart `mongod`, connect with `mongo` shell.

[^Upgrade a Cluster to user TLS/SSL]: https://docs.mongodb.com/manual/tutorial/upgrade-cluster-to-ssl/

```
/usr/bin/mongo --ssl -u mongoadm -p secret localhost/admin --sslPEMKeyFile /etc/ssl/client.pem --sslCAFile /etc/ssl/ca.crt
/usr/bin/mongo --ssl -u mongoadm -p secret localhost/admin --sslAllowInvalidCertificates
/usr/bin/mongo --ssl -u appuser -p secret localhost/test --sslPEMKeyFile /etc/ssl/client.pem --sslCAFile /etc/ssl/ca.crt --authenticationDatabase admin
```

Finally, update `/etc/mongod.conf` to change ssl mode to `requireSSL`.

```
net:
  ssl:
    mode: requireSSL
    PEMKeyFile: /etc/ssl/server.pem
    CAFile: /etc/ssl/ca.crt
```

### Connect to AWS from Remote
Add AWS DNS names to `/etc/hosts`

```
172.31.62.119 ip-172-31-1-1.ec2.internal ec2-52-91-1-1.compute-1.amazonaws.com
172.31.49.218 ip-172-31-2-2.ec2.internal ec2-54-210-2-2.compute-1.amazonaws.com
172.31.57.167 ip-172-31-3-3.ec2.internal ec2-54-157-3-3.compute-1.amazonaws.com
```

Connect using

```
mongo mongodb://mongoadm:secret@ip-172-31-1-1.ec2.internal/test?authSource=admin --ssl --sslPEMKeyFile ~/ssl/client.pem --sslCAFile ~/ssl/ca.crt

mongo mongodb://mongoadm:secret@ip-172-31-1-1.ec2.internal,ip-172-31-2-2.ec2.internal,ip-172-31-3-3.ec2.internal/admin?authSource=admin\&replicaSet=rs-dev --ssl --sslPEMKeyFile ~/ssl/client.pem --sslCAFile ~/ssl/ca.crt
```

## Java Test

### Import Certs to Keystore
You need `client.pem` and `ca.crt` files.

```
cd /etc/ssl
openssl pkcs12 -export -out keystore.p12 -inkey client.pem -in client.pem
keytool -importkeystore -destkeystore keystore.jks -srcstoretype PKCS12 -srckeystore keystore.p12
keytool -importcert -trustcacerts -file ca.crt -keystore truststore.jks
```

### Java Example

```
package ssl;

import com.mongodb.Block;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoIterable;

public class MongoSSL {
	public void connect() {
        String [] hosts = {"ip-172-31-1-1.ec2.internal", "ip-172-31-2-2.ec2.internal", "ip-172-31-3-3.ec2.internal"};
        String url = "mongodb://mongoadm:secret@" + String.join(",", hosts) + "/admin?authSource=admin&ssl=true&replicaSet=rs-dev";
		
        System.setProperty("javax.net.ssl.keyStore", "/etc/ssl/keystore.jks");
        System.setProperty("javax.net.ssl.keyStorePassword", "secret");
        System.setProperty("javax.net.ssl.keyStoreType", "JKS");

        System.setProperty("javax.net.ssl.trustStore", "/etc/ssl/truststore.jks");
        System.setProperty("javax.net.ssl.trustStorePassword", "secret");
        System.setProperty("javax.net.ssl.trustStoreType", "JKS");
        
        MongoClient client = new MongoClient(new MongoClientURI(url));
        MongoIterable<String> listDatabaseNames = client.listDatabaseNames();
        Block<String> printer = System.out::println;
        listDatabaseNames.forEach(printer);        
        client.close();
	}

	public static void main(String[] args) {
        MongoSSL mssl = new MongoSSL();
        mssl.connect();
	}
}
```

## /etc/mongod.conf
```
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# Where and how to store data.
storage:
  dbPath: /data/db
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/mongod.pid  # location of pidfile
  timeZoneInfo: /usr/share/zoneinfo

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1,172.31.62.119  # Listen to local interface only, comment to listen on all interfaces.
  ssl:
    mode: requireSSL
    PEMKeyFile: /etc/ssl/server.pem
    CAFile: /etc/ssl/ca.crt

security:
  authorization: enabled
  keyFile: /etc/ssl/rs0-dev.keyfile
  enableEncryption: true
  encryptionKeyFile: /etc/ssl/enc-keyfile

#operationProfiling:

replication:
  replSetName: "rs-dev"

#sharding:

## Enterprise-Only Options

#auditLog:

#snmp:
```

### Files
```
/etc
├── fstab
├── hosts
├── init.d -> rc.d/init.d
├── mongod.conf
├── rc.d
│   ├── init.d
│   │   ├── disable-transparent-hugepages
├── security
│   ├── limits.d
│   │   └── 20-nproc.conf
├── selinux
│   ├── config
├── ssl
│   ├── ca.crt
│   ├── enc-keyfile
│   ├── keystore.jks
│   ├── mongodb-cert.crt
│   ├── mongodb-cert.key
│   ├── rs0-dev.keyfile
│   ├── server.pem
│   └── truststore.jks
└── yum.repos.d
    └── mongodb-enterprise.repo

/data
└── db
    ├── collection-0--52200788745683527.wt
    ├── collection-1-8115530982417621065.wt
    ├── diagnostic.data
    │   ├── metrics.2017-12-25T10-16-00Z-00000
    │   ├── metrics.2017-12-25T10-20-26Z-00000
    │   └── metrics.interim
    ├── index-1--52200788745683527.wt
    ├── mongod.lock
    ├── sizeStorer.wt
    ├── storage.bson
    ├── WiredTiger
    ├── WiredTigerLAS.wt
    ├── WiredTiger.lock
    ├── WiredTiger.turtle
    └── WiredTiger.wt
```

