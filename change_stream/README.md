# Change Stream Examples
## Mongo Shell

```
> cursor = db.apps.watch()
> doc =
{
	"_id" : ObjectId("5a4ffc8a6d9a3697fcc494bd"),
	"name" : "abc",
	"versions" : [
		"101",
		"102",
		"103"
	]
}

> db.apps.insert(doc)
> db.apps.find({name: "abc"}).pretty()
{
	"_id" : ObjectId("5a4ffc8a6d9a3697fcc494bd"),
	"name" : "abc",
	"versions" : [
		"101",
		"102",
		"103"
	]
}

> db.apps.update({ name: "abc"}, {$push: { versions: "104" }})
> cursor.next()
{
	"_id" : {
		"_data" : BinData(0,"glpQAD8AAAABRmRfaWQAZFpP/IptmjaX/MSUvQBaEAQJk0ZWeQ1G/5zFikqpXugfBA==")
	},
	"operationType" : "update",
	"ns" : {
		"db" : "test",
		"coll" : "apps"
	},
	"documentKey" : {
		"_id" : ObjectId("5a4ffc8a6d9a3697fcc494bd")
	},
	"updateDescription" : {
		"updatedFields" : {
			"versions.3" : "104"
		},
		"removedFields" : [ ]
	}
}

> db.apps.update({ name: "abc"}, {$pop: { versions: -1 }})
> db.apps.find({name: "abc"}).pretty()
{
	"_id" : ObjectId("5a4ffc8a6d9a3697fcc494bd"),
	"name" : "abc",
	"versions" : [
		"102",
		"103",
		"104"
	]
}

> cursor.next()
{
	"_id" : {
		"_data" : BinData(0,"glpQAI4AAAABRmRfaWQAZFpP/IptmjaX/MSUvQBaEAQJk0ZWeQ1G/5zFikqpXugfBA==")
	},
	"operationType" : "update",
	"ns" : {
		"db" : "test",
		"coll" : "apps"
	},
	"documentKey" : {
		"_id" : ObjectId("5a4ffc8a6d9a3697fcc494bd")
	},
	"updateDescription" : {
		"updatedFields" : {
			"versions" : [
				"102",
				"103",
				"104"
			]
		},
		"removedFields" : [ ]
	}
}
```

## Change Stream -> MQTT
### Python

```
./change_stream.py
```

### Node.js

```
npm install
node change_stream.js
```

### Test
#### MQTT Consumer

```
pip install paho-mqtt
./mqtt_listener.py
```

#### Simulator

```
mlaunch init --dir ~/ws/cs --replicaset
mongo --quiet mongodb://localhost:27017/orders?replicaSet=replset < change_stream_sim.js
```
