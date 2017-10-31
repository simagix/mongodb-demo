# MongoDB Sort Stages Demo
Demo different indexes affecting performance on queries with sorting.  Use a compound index with the sorting parameter in the index can prevent MongoDB engine to perform sorting in memory. 
## Populate Data
Populate a collection with documents having two fields _a_ and _b_.
```
> use SORTDB
> var bulk = db.values.initializeUnorderedBulkOp();
> for(i = 0; i < 1000; i++) { bulk.insert({ a: Math.round(Math.random() * 100), b: Math.round(Math.random() * 10) }); }
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
Find all documents with _a_ equals 25 or 50, and sorted by b ascendingly.
```
> db.values.explain("executionStats").find( { a: {$in: [25, 50]} } ).sort({ b: 1 })
```
### No Index
Execute the query without any index on the collection, and it results a full collection scan (_COLLSCAN_).
```
version : 3.4.9
-- FILTER --
{
   "a": {
      "$in": [
         25,
         50
      ]
   }
}

-- SUMMARY --
executionTimeMillis : 0
nReturned : 25
totalKeysExamined : 0
totalDocsExamined : 1000

-- STAGES --
SORT
|  - executionTimeMillisEstimate : 0
|  - nReturned : 25
+--SORT_KEY_GENERATOR
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 25
.  +--COLLSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 25
.  .  |  - docsExamined : 1000
```
### Single Field Index
Execute the query with an index of `{ a: 1 }` on the collection, it utilizes the index (_IXSCAN_ stage) for search but loads data in memory before sorting.
```
> db.values.createIndex( { a: 1 } )
{
	"createdCollectionAutomatically" : false,
	"numIndexesBefore" : 1,
	"numIndexesAfter" : 2,
	"ok" : 1
}
```
Explain() result:
```
-- SUMMARY --
executionTimeMillis : 0
nReturned : 25
totalKeysExamined : 27
totalDocsExamined : 25

-- STAGES --
SORT
|  - executionTimeMillisEstimate : 0
|  - nReturned : 25
+--SORT_KEY_GENERATOR
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 25
.  +--FETCH
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 25
.  .  |  - docsExamined : 25
.  .  +--IXSCAN
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 25
.  .  .  |  - keysExamined : 27
.  .  .  |  - index used : a_1
```
### Compound Index
Adding a compound index `{ a: 1, b: 1}` then executing the query, it not only use the index to search, but also merge data without fetching them into memory to sort.
```
> db.values.createIndex( { a: 1, b: 1 } )
{
	"createdCollectionAutomatically" : false,
	"numIndexesBefore" : 2,
	"numIndexesAfter" : 3,
	"ok" : 1
}
```
Explain() result:
```
-- SUMMARY --
executionTimeMillis : 0
nReturned : 25
totalKeysExamined : 25
totalDocsExamined : 25

-- STAGES --
FETCH
|  - executionTimeMillisEstimate : 0
|  - nReturned : 25
|  - docsExamined : 25
+--SORT_MERGE
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 25
.  +--IXSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 10
.  .  |  - keysExamined : 10
.  .  |  - index used : a_1_b_1
.  +--IXSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 15
.  .  |  - keysExamined : 15
.  .  |  - index used : a_1_b_1
```