# MongoDB Sort Stages with Multi-keys Demo
This demos multi-key indexes, the use of _$elemMatch_, and different indexes affecting performance. 
## Populate Data
Populate a collection with documents having an array of sub-documents and a date/time field.
```
> use SORTDB
> var bulk = db.multikeys.initializeUnorderedBulkOp()
> for(i = 0; i < 1000; i++) {
    bulk.insert({  stats: [
        {a: Math.round(Math.random()*10), 
            b: Math.round(Math.random()*10)},
        {c: Math.round(Math.random()*10), 
            d: Math.round(Math.random()*10)}
    ],
    dt: new Date() })
}
> bulk.execute()
BulkWriteResult({
	"writeErrors" : [ ],
	"writeConcernErrors" : [ ],
	"nInserted" : 1000,
	"nUpserted" : 0,
	"nMatched" : 0,
	"nModified" : 0,
	"nRemoved" : 0,
	"upserted" : [ ]
})
```

## Use Case
Find all documents with both _a_ and _b_ equal 5 or both _a_ and _b_ equal to 8, and sorted by _dt_ descendingly.
```
> db.multikeys.explain("executionStats").find(
    { stats: {$elemMatch:  {$or: [{a: 5, b: 5}, {c: 8, d: 8}] } } }
).sort( { dt: -1} )
```
### No Index
Execute the query without any index on the collection, and it results a full collection scan (_COLLSCAN_).
```
version : 3.4.9
-- FILTER --
{
   "stats": {
      "$elemMatch": {
         "$or": [
            {
               "$and": [
                  {
                     "a": {
                        "$eq": 5
                     }
                  },
                  {
                     "b": {
                        "$eq": 5
                     }
                  }
               ]
            },
            {
               "$and": [
                  {
                     "a": {
                        "$eq": 8
                     }
                  },
                  {
                     "b": {
                        "$eq": 8
                     }
                  }
               ]
            }
         ]
      }
   }
}

-- SUMMARY --
executionTimeMillis : 1
nReturned : 16
totalKeysExamined : 0
totalDocsExamined : 1000

-- STAGES --
SORT
|  - executionTimeMillisEstimate : 0
|  - nReturned : 16
+--SORT_KEY_GENERATOR
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 16
.  +--COLLSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 16
.  .  |  - docsExamined : 1000
```
### Multi-key Index
Execute the query with an index of `{ "stats.a": 1, "stats.b": 1 }` on the collection, it utilizes the index (_IXSCAN_ stage) for search but loads data in memory before sorting.
```
> db.multikeys.createIndex({ "stats.a": 1, "stats.b": 1 })
{
	"createdCollectionAutomatically" : false,
	"numIndexesBefore" : 1,
	"numIndexesAfter" : 2,
	"ok" : 1
}
```

```
-- SUMMARY --
executionTimeMillis : 9
nReturned : 16
totalKeysExamined : 16
totalDocsExamined : 16

-- STAGES --
SORT
|  - executionTimeMillisEstimate : 0
|  - nReturned : 16
+--SORT_KEY_GENERATOR
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 16
.  +--FETCH
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 16
.  .  |  - docsExamined : 16
.  .  +--OR
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 16
.  .  .  +--IXSCAN
.  .  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  .  |  - nReturned : 9
.  .  .  .  |  - keysExamined : 9
.  .  .  .  |  - index used : stats.a_1_stats.b_1
.  .  .  +--IXSCAN
.  .  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  .  |  - nReturned : 7
.  .  .  .  |  - keysExamined : 7
.  .  .  .  |  - index used : stats.a_1_stats.b_1
```

### Compound Index
Adding a compound index `{ "stats.a": 1, "stats.b": 1 , "dt": 1}` then executing the query, it not only use the index to search, but also merge data without fetching them into memory to sort.
```
> db.multikeys.createIndex({ "stats.a": 1, "stats.b": 1, "dt": 1 })
{
	"createdCollectionAutomatically" : false,
	"numIndexesBefore" : 2,
	"numIndexesAfter" : 3,
	"ok" : 1
}
```
```
-- SUMMARY --
executionTimeMillis : 1
nReturned : 16
totalKeysExamined : 16
totalDocsExamined : 16

-- STAGES --
FETCH
|  - executionTimeMillisEstimate : 0
|  - nReturned : 16
|  - docsExamined : 16
+--SORT_MERGE
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 16
.  +--IXSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 9
.  .  |  - keysExamined : 9
.  .  |  - index used : stats.a_1_stats.b_1_dt_1
.  +--IXSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 7
.  .  |  - keysExamined : 7
.  .  |  - index used : stats.a_1_stats.b_1_dt_1
```
