# Ops Manager API Example
[Automate Backup Restoration through the API](https://docs.opsmanager.mongodb.com/v3.4/tutorial/automate-backup-restoration-with-api/)

```
export EMAIL=ken.chen@mongodb.com
export APIKEY=9020fa7b-298a-47e1-bf23-cb9f247f6810
export OPSMGRURL=http://localhost:8080
export GROUPID=5a7c78402293160bdbcc7ff3
export CLUSTERID=5aac04792293162928065c37
```

## 1. Verify API
```
curl -u "$EMAIL:$APIKEY" --digest -i "$OPSMGRURL/api/public/v1.0/groups"
curl -u "$EMAIL:$APIKEY" --digest -i "$OPSMGRURL/api/public/v1.0/groups?pretty=true"
```

## 2. Create User
```
curl -u "$EMAIL:$APIKEY" -H "Content-Type: application/json" --digest -i -X POST "$OPSMGRURL/api/public/v1.0/users" --data-binary "@user.json"
```

## 3. Backup and Restore
### 3.1. Backup Config
```
curl -u "$EMAIL:$APIKEY" -H "Content-Type: application/json" --digest -i -X GET "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/backupConfigs"
curl -u "$EMAIL:$APIKEY" -H "Content-Type: application/json" --digest -i -X GET "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/backupConfigs/$CLUSTERID"
```

### 3.2. Retrieve the snapshot ID
```
curl -i -u "$EMAIL:$APIKEY" --digest "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/clusters/$CLUSTERID/snapshots"
```

### 3.3. Create a restore job for the snapshot
```
export SNAPSHOTID=5aadbc2e2293160f38e6aaa3
curl -i -u "$EMAIL:$APIKEY" -H "Content-Type: application/json" --digest -X POST "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/clusters/$CLUSTERID/restoreJobs" --data '
{
  "snapshotId": "5aadbc2e2293160f38e6aaa3"
}'
```

### 3.4. Retrieve the restore link
```
curl -i -u "$EMAIL:$APIKEY" --digest "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/clusters/$CLUSTERID/restoreJobs"
```

### 3.5 Retrieve the automation configuration
```
curl -u "$EMAIL:$APIKEY" "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/automationConfig" --digest -i
```

### 3.6. Add the restore link to the automation configuration
Add `backupRestoreUrl` to the result from above.

```
"processes" : [
  {
    ... ,
    "hostname" : "ip-172-31-49-218.ec2.internal",
    "backupRestoreUrl" : "http://172.31.13.35:8080/backup/restore/v2/pull/d13ef09a6ea006618210620a9c2b7b95/5aac08bf2293162928066d0d/-8825942812630368616/repl2-1521223194-5aac08bf2293162928066d0d.tar",
    ...
  },
  ...
]
```

### 3.7. Send the updated automation configuration
```
curl -u "$EMAIL:$APIKEY" -H "Content-Type: application/json" "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/automationConfig" --digest -i -X PUT --data @<configuration>
```

### 3.8. Confirm successful update of the automation configuration
```
curl -u "$EMAIL:$APIKEY" "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/automationConfig" --digest -i
```

### 3.9. Check the deployment status to ensure goal state is reached.
```
curl -u "$EMAIL:$APIKEY" "$OPSMGRURL/api/public/v1.0/groups/$GROUPID/automationStatus" --digest -i
```

