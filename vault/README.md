# MongoDB with Hashicorp Vault
Integrate MongoDB with Hashicorp vault.

## Start Vault Server (dev)
```
$ vault server -dev
==> Vault server configuration:

             Api Address: http://127.0.0.1:8200
                     Cgo: disabled
         Cluster Address: https://127.0.0.1:8201
              Listener 1: tcp (addr: "127.0.0.1:8200", cluster address: "127.0.0.1:8201", tls: "disabled")
               Log Level: info
                   Mlock: supported: false, enabled: false
                 Storage: inmem
                 Version: Vault v0.10.1
             Version Sha: 756fdc4587350daf1c65b93647b2cc31a6f119cd

WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.

You may need to set the following environment variable:

    $ export VAULT_ADDR='http://127.0.0.1:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: SddB6S4LajBysQimDaWlCzafgiTFi8dTLcT62bHCZ6M=
Root Token: 470a1057-49c8-2c2d-c5e7-debdacd6b4f3
...
```

## Login to Vault
On a terminal,

```
$ export VAULT_ADDR='http://127.0.0.1:8200'

$ vault login 470a1057-49c8-2c2d-c5e7-debdacd6b4f3
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.
```

## Vault MongoDB Plugin

### Start MongoDB
```
$ mlaunch init --dir ~/ws/vault --single --auth
```

### Register mongod
```
$ vault secrets enable database

vault write database/config/my-mongodb-database \
    plugin_name=mongodb-database-plugin \
    allowed_roles="my-role" \
    connection_url="mongodb://{{username}}:{{password}}@localhost:27017/admin" \
    username="user" \
    password="password"

$ vault read database/config/my-mongodb-database

Key                                   Value
---                                   -----
allowed_roles                         [my-role]
connection_details                    map[connection_url:mongodb://{{username}}:{{password}}@localhost:27017/admin username:user]
plugin_name                           mongodb-database-plugin
root_credentials_rotate_statements    []
```

### Create Role
```
$ vault write database/roles/my-role \
    db_name=my-mongodb-database \
    creation_statements='{ "db": "admin", "roles": [{ "role": "readWrite" }, {"role": "readWrite", "db": "foo"}] }' \
    default_ttl="1h" \
    max_ttl="24h"
```

### Get Credential
```
$ vault read database/creds/my-role

Key                Value
---                -----
lease_id           database/creds/my-role/22b019c2-4df3-20ad-4098-2ebe6dda21e1
lease_duration     1h
lease_renewable    true
password           A1a-74s66685pzyvwyq9
username           v-root-my-role-4ry7198r0p6sw8829ywt-1524836257
```

### Connect to mongod
```
$ mongo mongodb://v-root-my-role-4ry7198r0p6sw8829ywt-1524836257:A1a-74s66685pzyvwyq9@localhost/foo?authSource=admin --eval 'db.keys.insert({key: 123 })'

WriteResult({ "nInserted" : 1 })

$ mongo mongodb://v-root-my-role-4ry7198r0p6sw8829ywt-1524836257:A1a-74s66685pzyvwyq9@localhost/foo?authSource=admin --eval 'db.keys.find({key: 123 })'

{ "_id" : ObjectId("5ae327e6c959c4b3b0593c71"), "key" : 123 }
```

### What Happened
```
db.getUsers()
[
	{
		"_id" : "admin.user",
		"user" : "user",
		"db" : "admin",
		"roles" : [
			{
				"role" : "dbAdminAnyDatabase",
				"db" : "admin"
			},
			{
				"role" : "readWriteAnyDatabase",
				"db" : "admin"
			},
			{
				"role" : "userAdminAnyDatabase",
				"db" : "admin"
			},
			{
				"role" : "clusterAdmin",
				"db" : "admin"
			}
		]
	},
	{
		"_id" : "admin.v-root-my-role-4ry7198r0p6sw8829ywt-1524836257",
		"user" : "v-root-my-role-4ry7198r0p6sw8829ywt-1524836257",
		"db" : "admin",
		"roles" : [
			{
				"role" : "readWrite",
				"db" : "admin"
			},
			{
				"role" : "readWrite",
				"db" : "foo"
			}
		]

	}
]
```
