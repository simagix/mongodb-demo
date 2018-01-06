### Active Directory Server
Use *ldap.forumsys.com* to simulate an Active Directory server.  Note that The users are not directly part of the groups (OU) they are members via the uniqueMember attribute. The users themselves reside under “dc=example,dc=com”.

For example the DN of gauss is “uid=gauss,dc=example,dc=com”. You will need to adjust the parameters on your LDAP bind to account for the use of uniqueMember as the way to tie users to groups.

To make this work, we need to create a group fisrt then assign users under the group, for example `mongoadm` group.

```
db.createRole( 
  { 
    role: "cn=<admin_group>,dc=example,dc=com", 
    privileges: [], 
    roles: [ "userAdminAnyDatabase" ] 
  }
)

db.createRole( 
  { 
    role: "cn=mongoadm,dc=example,dc=com", 
    privileges: [], 
    roles: [ "userAdminAnyDatabase" ] 
  }
)
```

```
ldapsearch -x -D "cn=read-only-admin,dc=example,dc=com" -b "ou=mathematicians,dc=example,dc=com" -w password -H ldap://ldap.forumsys.com
ldapsearch -x -D "cn=read-only-admin,dc=example,dc=com" -b "ou=mathematicians,dc=example,dc=com" -w password -H ldap://ldap.forumsys.com -s sub "uid=gauss"
```

```
mongo --username 'gauss' --password 'password' --authenticationMechanism 'PLAIN' --authenticationDatabase '$external' --eval 'db'
mongo --username 'read-only-admin' --password 'password' --authenticationMechanism 'PLAIN' --authenticationDatabase '$external' --eval 'db'
```

```
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /Users/kenchen/ws/active_dir/mongod.log

# Where and how to store data.
storage:
  dbPath: /Users/kenchen/ws/active_dir
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /Users/kenchen/ws/active_dir/mongod.pid  # location of pidfile
  timeZoneInfo: /usr/share/zoneinfo

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1 # Listen to local interface only, comment to listen on all interfaces.

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