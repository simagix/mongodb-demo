# Utilities
## redact_shema.js
Display the document structure of a collection with redacted data.

Usage:

```
mongo --quiet --eval 'var database="$database", collection="$collection"' redact_schema.js
```

Example:
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
{
	"_id" : {
		"$oid" : "String"
	},
	"a" : "String",
	"b" : 0,
	"c" : false,
	"d" : "ISODate(...)"
}
```
