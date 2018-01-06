### Change Stream

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