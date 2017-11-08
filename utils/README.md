# Utilities
## redact_shema.js
Display the document structure of a collection with redacted data.

Usage:

```
mongo --quiet --eval 'var database="$database", collection="$collection"' redact_schema.js
```

### Example 1: Get _schema_ with given database and collection names
```
mongo --quiet --eval 'var database="WSDB", collection="redacts"' redact_schema.js
```
The above command find the first document of _WSDB.redacts_ as
```
{
	"_id" : ObjectId("5a031571435ebc1ef985488f"),
	"a" : "Very sensitive data of backing accounts",
	"b" : 123,
	"c" : false,
	"d" : ISODate("2017-11-08T14:32:17.441Z")
}
```
and display it as
```
[
	{
		"ns" : "WSDB.redacts",
		"schema" : {
			"_id" : "ObjectId",
			"a" : "String",
			"b" : 0,
			"c" : false,
			"d" : "ISODate(...)"
		}
	}
]
```
### Example 2: Get all _schemas_ of a database
```
mongo --quiet --eval 'var database="WSDB"' redact_schema.js
```
### Example 3: Get all _schemas_ except admin, local, and test database
```
mongo --quiet redact_schema.js
```
