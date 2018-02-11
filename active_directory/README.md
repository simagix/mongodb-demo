# MongoDB and Active Directory Server
- [Authenticate Using SASL and LDAP with ActiveDirectory](https://docs.mongodb.com/manual/tutorial/configure-ldap-sasl-activedirectory/)
- [Authenticate and Authorize Users Using Active Directory via Native LDAP](https://docs.mongodb.com/manual/tutorial/authenticate-nativeldap-activedirectory/)
- [LDAP Authorization](https://docs.mongodb.com/manual/core/security-ldap-external/)

## Native LDAP Example
Use *ldap.forumsys.com* to simulate an Active Directory server.  Note that The users are not directly part of the groups (OU) they are members via the uniqueMember attribute. The users themselves reside under “dc=example,dc=com”.

For example the DN of gauss is “uid=gauss,dc=example,dc=com”. You will need to adjust the parameters on your LDAP bind to account for the use of uniqueMember as the way to tie users to groups.

To make this work, we need to create a group fisrt then assign users under the group, for example `mongoadm` group.

```
var admin = db.getSiblingDB("admin")
admin.createRole( { 
    role: "cn=<admin_group>,dc=example,dc=com", 
    privileges: [], 
    roles: [ "userAdminAnyDatabase" ] 
} )

admin.createRole({ 
    role: "cn=mongoadm,dc=example,dc=com", 
    privileges: [], 
    roles: [ "userAdminAnyDatabase" ] 
} )

admin.createRole( {
    role: "ou=People,dc=mongo,dc=local",
    privileges: [],
    roles: [ "userAdminAnyDatabase" ]
} )
```

### `/etc/mongod.conf`
```
# mongod.conf
systemLog:
  destination: file
  logAppend: true
  path: /Users/kenchen/ws/active_dir/mongod.log

# Where and how to store data.
storage:
  dbPath: /Users/kenchen/ws/active_dir
  journal:
    enabled: true

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /Users/kenchen/ws/active_dir/mongod.pid  # location of pidfile
  timeZoneInfo: /usr/share/zoneinfo

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1

security:
  authorization: enabled
  ldap:
    transportSecurity: none
    servers: "ldap.forumsys.com"
    bind:
       queryUser: "cn=read-only-admin,dc=example,dc=com"
       queryPassword: "password"
    authz:
      queryTemplate:
        "dc=example,dc=com??sub?(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={USER}))"
    userToDNMapping:
      '[
        {
          match: "(read-only-admin)",
          substitution: "cn={0},dc=example,dc=com"
        },
        {
          match: "(.+)",
          substitution: "uid={0},dc=example,dc=com"
        }
      ]'

setParameter:
  authenticationMechanisms: 'PLAIN'

```

### Test LDAP

```
ldapsearch -x -D "cn=read-only-admin,dc=example,dc=com" -b "ou=mathematicians,dc=example,dc=com" -w password -H ldap://ldap.forumsys.com
ldapsearch -x -D "cn=read-only-admin,dc=example,dc=com" -b "ou=mathematicians,dc=example,dc=com" -w password -H ldap://ldap.forumsys.com -s sub "uid=gauss"
ldapsearch -x -D "cn=read-only-admin,dc=example,dc=com" -b "dc=example,dc=com" -w password -H ldap://ldap.forumsys.com -s sub '(objectclass=*)'
ldapsearch -x -D "uid=ken,ou=People,dc=mongo,dc=local" -w happy123 -H ldap://ec2-52-207-234-214.compute-1.amazonaws.com -b "dc=mongo,dc=local" -s sub '(objectclass=*)'
```

```
mongo --username 'gauss' --password 'password' --authenticationMechanism 'PLAIN' --authenticationDatabase '$external' --eval 'db'
mongo --username 'read-only-admin' --password 'password' --authenticationMechanism 'PLAIN' --authenticationDatabase '$external' --eval 'db'
```

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