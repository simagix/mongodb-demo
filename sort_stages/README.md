# MongoDB Sort Stages Demo
Demo different indexes affecting performance.
## Populate Data
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
```
> db.values.explain("executionStats").find( { a: {$in: [25, 50]} } ).sort({ b: 1 })
```
### No Index
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