# MongoDB Integration with OpenShift
## Minishift
```
# minishift delete --clear-cache
minishift delete
minishift start
minishift docker-env
eval $(minishift docker-env)
docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
```

### Permission

```
oc login -u system:admin
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-group anyuid system:authenticated
oc adm policy add-cluster-role-to-user cluster-admin developer
oc adm policy add-cluster-role-to-user cluster-admin admin
```

## Build Image
```
docker build . -t simagix/mongo-oc-repl:3.6
```

## Start a Replica
```
oc login -u developer
oc new-app openshift-replica.yaml
```

```
--> Deploying template "myproject/mongod-replica" for "openshift-replica.yaml" to project myproject

     mongod-replica
     ---------
     MongoDB Replication Example (based on StatefulSet). You must have persistent volumes available in your cluster to use this template.

     * With parameters:
        * MongoDB Connection Username=BLf # generated
        * MongoDB Connection Password=mgbsSQ5qUNJVjYbK # generated
        * MongoDB Database Name=sampledb
        * MongoDB Admin Password=Lx3sDBV8n4GIV4Ck # generated
        * Replica Set Name=rs0
        * Keyfile Content=3AUK6GFE61Jsg0FR3W4prUeHqcUR6elb2l4oMjU0oUxwlJ2p5yuPJ0D1aGNfp7emDYJloyas5viptf0vw4jYQE7A0jnJ304pwfyQmTl0aKdBN72mcoGeqnsnU5sORMrTjaXR4RdNjUV1XdY3WbCQ5QMTJMwyNiDq4qg1XVEqrf116d8BxlwKXu57LQEUMlkbhSkLbDtCM2cUSuMXjMWv5ycb5iVGhQgQLyEplpdUeXKop8O7VLReWKlYUDiqxWJ # generated
        * MongoDB Container Image=simagix/mongo-oc-repl:3.6
        * OpenShift Service Name=ocmongo
        * Volume Capacity=1Gi
        * Memory Limit=512Mi

--> Creating resources ...
    service "ocmongo" created
    service "ocmongo-internal" created
    statefulset "ocmongo" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/ocmongo'
     'oc expose svc/ocmongo-internal'
    Run 'oc status' to view your app.
```

## Check Status
```
$ oc get dc,svc,is,pvc
NAME                   CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
svc/ocmongo            172.30.155.122   <none>        27017/TCP   12m
svc/ocmongo-internal   None             <none>        27017/TCP   12m

NAME                       STATUS    VOLUME    CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc/mongo-data-ocmongo-0   Bound     pv0058    100Gi      RWO,ROX,RWX                  16m
pvc/mongo-data-ocmongo-1   Bound     pv0097    100Gi      RWO,ROX,RWX                  16m
pvc/mongo-data-ocmongo-2   Bound     pv0039    100Gi      RWO,ROX,RWX                  16m
```

## Misc. Command
```
oc delete all --all
oc get pods -l name=ocmongo
```
