# MongoDB Count Demo
This demos different stages, _COUNT_SCAN_ and _IXSCAN_/_FETCH_, of count. 
## Populate Data
Populate a collection with documents.
```
> use SORTDB
> padding = '.-=+'
> db.records.createIndex({ key: 1 })
> bulk = db.records.initializeUnorderedBulkOp()
> for(i = 10000; i < 20000; i++) { m = 'key-' + (i % 5);  bulk.insert({ 'key': m, 'descr': m + padding }); }
> bulk.execute()
```
## Use Cases
Three use cases are presented, and they are queries of single value, multiple values, and a range of values, respectively.
### Query with Single Value
Query using a value on an indexes field, and the it execute the _SORT_SCAN_ stage.
```
> db.records.explain("executionStats").count({ "key": "key-1" })

version : 3.4.10
-- FILTER --
{
   "key": {
      "$eq": "key-1"
   }
}

-- SUMMARY --
executionTimeMillis : 2
nReturned : 0
totalKeysExamined : 2001
totalDocsExamined : 0

-- STAGES --
COUNT
|  - executionTimeMillisEstimate : 0
|  - nReturned : 0
+--COUNT_SCAN
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 2000
.  |  - keysExamined : 2001
.  |  - index used : key_1
```
### Query with Multiple Values
Query using two values on an indexes field, and the it execute the _IXSCAN_ as well as _FETCH_ stages.
```
> db.records.explain("executionStats").count({ "key": {$in: ["key-1", "key-2"] } })

version : 3.4.10
-- FILTER --
{
   "key": {
      "$in": [
         "key-1",
         "key-2"
      ]
   }
}

-- SUMMARY --
executionTimeMillis : 7
nReturned : 0
totalKeysExamined : 4001
totalDocsExamined : 4000

-- STAGES --
COUNT
|  - executionTimeMillisEstimate : 0
|  - nReturned : 0
+--FETCH
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 4000
.  |  - docsExamined : 4000
.  +--IXSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 4000
.  .  |  - keysExamined : 4001
.  .  |  - index used : key_1
```
### Query with a Range of Values
Query using a range of values on an indexes field, and the it execute the _COUNT_SCAN_ stages.
```
> db.records.explain("executionStats").count({ "key": {$gte: "key-1", $lte: "key-2" } })

version : 3.4.10
-- FILTER --
{
   "$and": [
      {
         "key": {
            "$lte": "key-2"
         }
      },
      {
         "key": {
            "$gte": "key-1"
         }
      }
   ]
}

-- SUMMARY --
executionTimeMillis : 1
nReturned : 0
totalKeysExamined : 4001
totalDocsExamined : 0

-- STAGES --
COUNT
|  - executionTimeMillisEstimate : 0
|  - nReturned : 0
+--COUNT_SCAN
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 4000
.  |  - keysExamined : 4001
.  |  - index used : key_1
```

## Design and Workaround
Many implementations commonly use a _status_ field to present the status of a document.  Before MongoDB 3.6, using multiple values with `$in` has overhead of fetching data into memory.  One solution to work around this is to count different status independently and sum the results together in the application.

On the other hand, we can add _status_code_ to the document and place different status into logical groups.  For example, assuming the application has two logical groups, and they are _active_ and _inactive_.  The _active_ group includes _complete_ and _pending_approval_.  On the other hand, the _inactive_ group has _suspeneded_, _terminated_, and _withdrew_.  We can assign status code between integer 1000 and 1999 to the _active_ group and 2000 to 2999 to the _inactive_ group.  Here is an example.
```
{
    "status_code": 1001
    "status": "complete"
}
```
Use integer values make it easy to query by a range of values, for example:
```
> db.records.explain("executionStats").count(
    {
        "status_code": {$gte: 1000, $lte: 1999 } 
    }
)
```
