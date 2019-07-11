# MongoDB Authenticating with Kerberos
This is a step by step runbook.

## Install Kerberos on RHEL/CentOS
### Yum Install
```
yum install -y krb5-server krb5-libs krb5-auth-dialog
yum install -y krb5-workstation krb5-libs krb5-auth-dialog
yum install -y krb5-pkinit-openssl
```

### Configuring a Kerberos 5 Server
Uncomment *EXAMPLE.COM* and replace *kerberos.example.com* with `$(hostname -f)`

#### /etc/krb5.conf
```
# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 pkinit_anchors = /etc/pki/tls/certs/ca-bundle.crt
default_realm = EXAMPLE.COM
 default_ccache_name = KEYRING:persistent:%{uid}

[realms]
EXAMPLE.COM = {
 kdc = ip-172-31-52-45.ec2.internal
 admin_server = ip-172-31-52-45.ec2.internal
}

[domain_realm]
.example.com = EXAMPLE.COM
example.com = EXAMPLE.COM
```

#### /var/kerberos/krb5kdc/kdc.conf
```
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 EXAMPLE.COM = {
  #master_key_type = aes256-cts
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal camellia256-cts:normal camellia128-cts:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
 }
```

#### /var/kerberos/krb5kdc/kadm5.acl
Leave the file as it is.

### Create Kerberos Database
```
/usr/sbin/kdb5_util create -s
Loading random data
Initializing database '/var/kerberos/krb5kdc/principal' for realm 'EXAMPLE.COM',
master key name 'K/M@EXAMPLE.COM'
You will be prompted for the database Master Password.
It is important that you NOT FORGET this password.
Enter KDC database master key:
Re-enter KDC database master key to verify:
```

### Create Admin access
Create the first principal.

```
/usr/sbin/kadmin.local -q "addprinc root/admin"
Authenticating as principal root/admin@EXAMPLE.COM with password.
WARNING: no policy specified for root/admin@EXAMPLE.COM; defaulting to no policy
Enter password for principal "root/admin@EXAMPLE.COM":
Re-enter password for principal "root/admin@EXAMPLE.COM":
Principal "root/admin@EXAMPLE.COM" created.
```

### Start Kerberos
```
/sbin/service krb5kdc start
/sbin/service kadmin start
```

### Add Principles
#### Service
By default mongos uses mongodb/<instance>@<realm>.

```
kadmin -r EXAMPLE.COM -p root/admin
Authenticating as principal root/admin with password.
Password for root/admin@EXAMPLE.COM:
kadmin:  addprinc mongodb/ip-172-31-52-45.ec2.internal
WARNING: no policy specified for mongodb/ip-172-31-52-45.ec2.internal@EXAMPLE.COM; defaulting to no policy
Enter password for principal "mongodb/ip-172-31-52-45.ec2.internal@EXAMPLE.COM":
Re-enter password for principal "mongodb/ip-172-31-52-45.ec2.internal@EXAMPLE.COM":
Principal "mongodb/ip-172-31-52-45.ec2.internal@EXAMPLE.COM" created.
```

#### Application Login
```
kadmin:  addprinc application/reporting
WARNING: no policy specified for application/reporting@EXAMPLE.COM; defaulting to no policy
Enter password for principal "application/reporting@EXAMPLE.COM":
Re-enter password for principal "application/reporting@EXAMPLE.COM":
Principal "application/reporting@EXAMPLE.COM" created.
```

### Create keytab file
```
ktutil
ktutil:  addent -password -p mongodb/ip-172-31-52-45.ec2.internal -k 1 -e aes256-cts
ktutil:  addent -password -p application/reporting -k 1 -e aes256-cts
Password for application/reporting@EXAMPLE.COM:
ktutil:  wkt /root/application.keytab
```

## Configure MongoDB
```
mkdir -p data/db
mongod --dbpath /root/data/db
```

### Create Ticket
```
kinit application/reporting@EXAMPLE.COM -kt /root/application.keytab
```

### Create User
```
mongo
use $external
db.createUser(
   {
     user: "application/reporting@EXAMPLE.COM",
     roles: [ { role: "read", db: "records" } ]
   }
)
```

### Enable Kerberos
```
env KRB5_KTNAME=/root/application.keytab mongod --auth \
    --setParameter authenticationMechanisms=GSSAPI \
    --dbpath /root/data/db \
    --bind_ip localhost,ip-172-31-52-45.ec2.internal
```

### Client
```
mongo --host ip-172-31-52-45.ec2.internal \
    --authenticationMechanism=GSSAPI \
    --authenticationDatabase='$external' \
    --username "application/reporting@EXAMPLE.COM"
```
