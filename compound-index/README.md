# MongoDB Compound Indexes
A common question about creating MongoDB compound indexes, how many is enough?  We often see indexes are created by using compound indexes.  For example, a collection has 3 fields, and they are a, b, and c, respectively.  Use often create indexes by query patterns as follows.

- Find {a: 101}, create index on {a: 1}
- Find {a: 101, b: 101}, create index on {a: 1, b: 1}
- Find {a: 101, c: 101}, create index on {a: 1, c: 1}
- Find {a: 101, b: 101, c: 101}, create index on {a: 1, b: 1, c: 1}
- Find {b: 101, c: 101}, create index on {b: 1, c: 1}

We may use one index {a: 1, b: 1, c: 1} to cover all above use cases, assuming a has high cardinality.

## Populate Data
```
function calc(n) { return Math.round(Math.random() * n); }

bulk = db.numbers.initializeUnorderedBulkOp();

for(i = 0; i < 100000; i++) {
    bulk.insert({a: calc(100), b: calc(50), c: calc(1000)})
}

bulk.execute()

db.numbers.createIndex( {a:  1 , b: 1 , c:  1} )
```

## Find {a: x}
Index on {a:  1 , b: 1 , c:  1} will cover the query pattern of {a: x}, and thus we can eliminate the index {a: 1}.

```
mongo compound --quiet --eval 'db.numbers.explain("executionStats").find({a: 50})'

version : 3.6.3
-- FILTER --
{
   "a": {
      "$eq": 50
   }
}

-- SUMMARY --
executionTimeMillis : 2
nReturned : 959
totalKeysExamined : 959
totalDocsExamined : 959

-- STAGES --
FETCH
|  - executionTimeMillisEstimate : 0
|  - nReturned : 959
|  - docsExamined : 959
+--IXSCAN
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 959
.  |  - keysExamined : 959
.  |  - index used : a_1_b_1_c_1
```

## Find {a: x, b: y}
Index on {a:  1 , b: 1 , c:  1} will also cover the query pattern of {a: x, b: y}, and thus we can eliminate the index {a: 1, b: 1}.

```
mongo compound --quiet --eval 'db.numbers.explain("executionStats").find({ a:  50 , $and: [{b: {$gt:  10}}, {b: {$lt:  20}}]})'

version : 3.6.3
-- FILTER --
{
   "$and": [
      {
         "a": {
            "$eq": 50
         }
      },
      {
         "b": {
            "$lt": 20
         }
      },
      {
         "b": {
            "$gt": 10
         }
      }
   ]
}

-- SUMMARY --
executionTimeMillis : 0
nReturned : 165
totalKeysExamined : 165
totalDocsExamined : 165

-- STAGES --
FETCH
|  - executionTimeMillisEstimate : 0
|  - nReturned : 165
|  - docsExamined : 165
+--IXSCAN
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 165
.  |  - keysExamined : 165
.  |  - index used : a_1_b_1_c_1
```

## Find {a: x, c: y}
Index on {a:  1 , b: 1 , c:  1} will also cover the query pattern of {a: x, c: y}, and thus we can eliminate the index {a: 1, c: 1}.

```
mongo compound --quiet --eval 'db.numbers.explain("executionStats").find({ a:  50 , $and: [{c: {$gt:  100}}, {c: {$lt:  200}}]})'

version : 3.6.3
-- FILTER --
{
   "$and": [
      {
         "a": {
            "$eq": 50
         }
      },
      {
         "c": {
            "$lt": 200
         }
      },
      {
         "c": {
            "$gt": 100
         }
      }
   ]
}

-- SUMMARY --
executionTimeMillis : 0
nReturned : 84
totalKeysExamined : 182
totalDocsExamined : 84

-- STAGES --
FETCH
|  - executionTimeMillisEstimate : 0
|  - nReturned : 84
|  - docsExamined : 84
+--IXSCAN
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 84
.  |  - keysExamined : 182
.  |  - index used : a_1_b_1_c_1
```

## Find {b: x, c: y} - Collection Scan
The query lacks of field a and this a collection scan is executed.  With a COLLSCAN, this query takes 24 ms.

```
mongo compound --quiet --eval 'db.numbers.explain("executionStats").find({ b:  50 , $and: [{c: {$gt:  100}}, {c: {$lt:  200}}]})'

version : 3.6.3
-- FILTER --
{
   "$and": [
      {
         "b": {
            "$eq": 50
         }
      },
      {
         "c": {
            "$lt": 200
         }
      },
      {
         "c": {
            "$gt": 100
         }
      }
   ]
}

-- SUMMARY --
executionTimeMillis : 36
nReturned : 99
totalKeysExamined : 0
totalDocsExamined : 100000

-- STAGES --
COLLSCAN
|  - executionTimeMillisEstimate : 24
|  - nReturned : 99
|  - docsExamined : 100000
```

## Find {b: x, c: y} with an Index
If field a exists in every document, we can play a trick by inserting { a: {$exists: 1} into the query, and thus IXSCAN is executed.

```
mongo compound --quiet --eval 'db.numbers.explain("executionStats").find({ a: {$exists: 1}, b:  50 , $and: [{c: {$gt:  100}}, {c: {$lt:  200}}]})'

version : 3.6.3
-- FILTER --
{
   "$and": [
      {
         "b": {
            "$eq": 50
         }
      },
      {
         "c": {
            "$lt": 200
         }
      },
      {
         "c": {
            "$gt": 100
         }
      },
      {
         "a": {
            "$exists": true
         }
      }
   ]
}

-- SUMMARY --
executionTimeMillis : 0
nReturned : 99
totalKeysExamined : 301
totalDocsExamined : 99

-- STAGES --
FETCH
|  - executionTimeMillisEstimate : 0
|  - nReturned : 99
|  - docsExamined : 99
+--IXSCAN
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 99
.  |  - keysExamined : 301
.  |  - index used : a_1_b_1_c_1
```

if field a doesn't exist in all document, still works.

```
mongo compound --quiet --eval 'db.numbers.explain("executionStats").find({$or: [{ a: {$exists: 1}}, {a: {$exists: 0}}], b:  50 , $and: [{c: {$gt:  100}}, {c: {$lt:  200}}]})'

version : 3.6.3
-- FILTER --
{
   "$and": [
      {
         "$or": [
            {
               "a": {
                  "$exists": true
               }
            },
            {
               "$nor": [
                  {
                     "a": {
                        "$exists": true
                     }
                  }
               ]
            }
         ]
      },
      {
         "b": {
            "$eq": 50
         }
      },
      {
         "c": {
            "$lt": 200
         }
      },
      {
         "c": {
            "$gt": 100
         }
      }
   ]
}

-- SUMMARY --
executionTimeMillis : 1
nReturned : 99
totalKeysExamined : 301
totalDocsExamined : 99

-- STAGES --
OR
|  - executionTimeMillisEstimate : 0
|  - nReturned : 99
+--FETCH
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 99
.  |  - docsExamined : 99
.  +--IXSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 99
.  .  |  - keysExamined : 301
.  .  |  - index used : a_1_b_1_c_1
+--FETCH
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 0
.  +--IXSCAN
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 0
.  .  |  - index used : a_1_b_1_c_1
```
