# MongoDB and Active Directory Server
- [Authenticate Using SASL and LDAP with ActiveDirectory](https://docs.mongodb.com/manual/tutorial/configure-ldap-sasl-activedirectory/)
- [Authenticate and Authorize Users Using Active Directory via Native LDAP](https://docs.mongodb.com/manual/tutorial/authenticate-nativeldap-activedirectory/)
- [LDAP Authorization](https://docs.mongodb.com/manual/core/security-ldap-external/)

## Native LDAP Example
A new example is at [MongoDB Enterprise Security Integration](https://github.com/simagix/mongodb-security).

## Using SASL Example
Using native LDAP, for now, requires placing plain password in the `mongod` configuration file, and such practice is not ideal nor acceptable by many organizations.  Instead, MongoDB has long supported LDAP using SASL.

### `/etc/sysconfig/saslauthd`
```
# Directory in which to place saslauthd's listening socket, pid file, and so
# on.  This directory must already exist.
# SOCKETDIR=/run/saslauthd
SOCKETDIR=/var/run/saslauthd

# Mechanism to use when checking passwords.  Run "saslauthd -v" to get a list
# of which mechanism your installation was compiled with the ablity to use.
# MECH=pam
MECH=ldap

# Additional flags to pass to saslauthd on the command line.  See saslauthd(8)
# for the list of accepted flags.
FLAGS=-V

DAEMONOPTS=--user saslauth
```

### `/etc/saslauthd.conf`
```
ldap_servers: ldap://localhost
# ldap_mech: DIGEST-MD5
# ldap_search_base: dc=mongo,dc=local
ldap_search_base: ou=People,dc=mongo,dc=local
ldap_filter: (uid=%u)
```

### `/etc/mongod.conf`
```
# mongod.conf
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# Where and how to store data.
storage:
  dbPath: /var/lib/mongo
  journal:
    enabled: true

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/mongod.pid  # location of pidfile

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1

# Chen
security:
  authorization: enabled

setParameter:
  saslauthdPath: /var/run/saslauthd/mux
  authenticationMechanisms: PLAIN
```

### Test SASL
```
mongo --host <host> --authenticationMechanism PLAIN --authenticationDatabase '$external' -u <user> -p
```
