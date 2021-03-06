<h3>MongoDB Sort Stages Demo</h3>

In this demo, two use cases are discussed.  The first case demos performance impacts from adding index(es) as well as single field vs. compound index.  The other case discusses how adding additional data field can improve query performance.  

When using sorting, `mongod` has different stages, and they are `SORT_MERGE` vs. `SORT`.  Ideally, it's more efficient to *merge* results from sorted data than fetching data into memory to sort.  In other words, we want to examining index (keys) only and avoid examining documents if possible.  


### 1. Use Case: Simple Query and Sort
The use case 1 queries on `{a : 1}` and sorts by `{b: 1}`.  Using a compound index of `{a: 1, b: 1}` can support both query and sorting.

#### 1.1. Populate Data
Populate a collection with documents having two fields _a_ and _b_.

```
use WSDB
var bulk = db.values.initializeUnorderedBulkOp();
for(i = 0; i < 1000; i++) { bulk.insert({ a: Math.round(Math.random() * 100), b: Math.round(Math.random() * 10) }); }
bulk.execute()
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

#### 1.2. Query Plan
Find all documents with _a_ equals to 25 or 50, and sorted by _b_ ascendingly.

```
db.values.explain("executionStats").find( { a: {$in: [25, 50]} } ).sort({ b: 1 })
```

#### 1.2.1. No Index
Execute the query without any index on the collection, and it enters a full collection scan stage (_COLLSCAN_).

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

#### 1.2.2. Use a Single Field Index
Execute the query with an index of `{ a: 1 }` on the collection, it utilizes the index (_IXSCAN_ stage) for search but has to fetch data in memory before sorting.

```
db.values.createIndex( { a: 1 } )
```

`Explain()` result:

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

#### 1.2.3. Use a Compound Index
Adding a compound index `{ a: 1, b: 1}` then executing the query, it not only use the index to search, but also merge data without fetching them into memory to sort.

```
db.values.createIndex( { a: 1, b: 1 } )
```

`Explain()` result:

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


### 2. Multi-keys Query
This demos multi-key indexes, the use of `$elemMatch`, and different indexes affecting performance. 

#### 2.1. Use Case
Find all documents with both _a_ and _b_ equal 5 or both _a_ and _b_ equal to 8, and sorted by _dt_ descendingly.
```
> db.multikeys.explain("executionStats").find(
    { stats: {$elemMatch:  {$or: [{a: 5, b: 5}, {a: 8, b: 8}] } } }
).sort( { dt: -1} )
```

#### 2.2. Populate Data
Populate a collection with documents having an array of sub-documents and a date/time field.

```
use WSDB
var bulk = db.multikeys.initializeUnorderedBulkOp()
for(i = 0; i < 1000; i++) {
  bulk.insert({  stats: [
      {a: Math.round(Math.random()*10), 
          b: Math.round(Math.random()*10)},
      {c: Math.round(Math.random()*10), 
          d: Math.round(Math.random()*10)}
  ],
  dt: new Date() })
}
bulk.execute()
```
#### 2.3. No Index
Execute the query without any index on the collection, and it results a full collection scan (`COLLSCAN`).

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

#### 2.4. Multi-key Index
##### 2.4.1. SORT Stage
Create a compound index.

```
db.multikeys.createIndex({ "stats.a": 1, "stats.b": 1 })
```

Execute the query with an index of `{ "stats.a": 1, "stats.b": 1 }` on the collection, it utilizes the index (`IXSCAN` stage) for search but loads data in memory before sorting.

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

##### 2.4.2. SORT_MERGE Stage
Adding a compound index 

```
db.multikeys.createIndex({ "stats.a": 1, "stats.b": 1, "dt": 1 })
```

Execute the same query, it not only uses the index to search, but also merges data without fetching them into memory to sort.

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

#### 2.5. Unequal Number of Fields
Remove _b_ from document where _a_ equals to 1.

```
db.multikeys.updateMany({ "stats.a": 1 }, { $set: { "stats.$": { "a": 1}}} )
```

Create an index on _b_.

```
db.multikeys.createIndex({ b: 1 })
```

Change the query to

```
db.multikeys.explain("executionStats").find(
    { stats: {$elemMatch:  {$or: [{a: 5, b: 5}, {b: null}] } } }
).sort( { dt: -1} )
```

The result shows data has to be sorted in the memory.  Note that `OR` stage is in place instead of `SORT_MERGE`.

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
               "b": {
                  "$eq": null
               }
            }
         ]
      }
   }
}

-- SUMMARY --
executionTimeMillis : 16
nReturned : 1000
totalKeysExamined : 1009
totalDocsExamined : 1000

-- STAGES --
SORT
|  - executionTimeMillisEstimate : 0
|  - nReturned : 1000
+--SORT_KEY_GENERATOR
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 1000
.  +--FETCH
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 1000
.  .  |  - docsExamined : 1000
.  .  +--OR
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 1000
.  .  .  +--IXSCAN
.  .  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  .  |  - nReturned : 9
.  .  .  .  |  - keysExamined : 9
.  .  .  .  |  - index used : stats.a_1_stats.b_1_dt_1
.  .  .  +--IXSCAN
.  .  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  .  |  - nReturned : 1000
.  .  .  .  |  - keysExamined : 1000
.  .  .  .  |  - index used : stats.b_1
```


### 3. Use Case: Addtional Field Improving Performance
Fetching data into memory to sort degrades performane.  The goal is to utilize `SORT_MERGE` stage when possible.  However, querying NULL values from an array using `$elemMatch` can force `mongod` to use `OR` and `SORT` stages, which requires fetching data before sorting.  For example, consider a document structure as follows:

```
{
  tags: [
    { name: "string", seq: "string" }
  ],
  dt: ISODate(...)
}
```

#### 3.1. Populate Date
```
names = ["AAA", "ABC", "BBB", "BCB", "CCC"]
seqs = ["123", "345", "789", "111", "222", "333", "555"]
t = new Date().getTime()
for(i = 0; i < 1000; i++) { 
  name = names[i % names.length]; 
  seq = seqs[i % seqs.length]; 
  dt = new Date(t - i * 10000);
  rand =  Math.round(Math.random()*10); 
  doc = {tags: [{name: name, seq: seq}], dt: dt, rand: rand}; 
  if(i % 12 == 0) 
    delete doc.tags[0].name; 
  else if(i % 31 == 0) 
    delete doc.tags[0].seq; 
  db.forms.insert(doc);  
}

db.forms.createIndex({rand: 1, dt: 1})
db.forms.createIndex({"tags.name": 1, "tags.seq": 1, dt: 1})
```

#### 3.2. Query Null Values in an Array
If the query filter is 

```
db.forms.find( {
  $or: [
    { rand: 5 },
    { tags: { $elemMatch: { name: { $in: [ "AAA", "ABC", "BBB"] } } } },
    { tags: { $elemMatch: { seq: { $in: [ "123", "345", "789"] }, name: null } } }
  ]
}).sort({dt: -1})
```

Below is the summary of `explain()`:

```
version : 3.4.10
-- FILTER --
{
   "$or": [
      {
         "tags": {
            "$elemMatch": {
               "$and": [
                  {
                     "name": {
                        "$eq": null
                     }
                  },
                  {
                     "seq": {
                        "$in": [
                           "123",
                           "345",
                           "789"
                        ]
                     }
                  }
               ]
            }
         }
      },
      {
         "tags": {
            "$elemMatch": {
               "name": {
                  "$in": [
                     "AAA",
                     "ABC",
                     "BBB"
                  ]
               }
            }
         }
      },
      {
         "rand": {
            "$eq": 5
         }
      }
   ]
}
-- SORT BY --
{
   "dt": -1
}

-- SUMMARY --
executionTimeMillis : 12
nReturned : 627
totalKeysExamined : 692
totalDocsExamined : 1212

-- STAGES --
SUBPLAN
|  - executionTimeMillisEstimate : 12
|  - nReturned : 627
+--SORT
.  |  - executionTimeMillisEstimate : 12
.  |  - nReturned : 627
.  +--SORT_KEY_GENERATOR
.  .  |  - executionTimeMillisEstimate : 12
.  .  |  - nReturned : 627
.  .  +--FETCH
.  .  .  |  - executionTimeMillisEstimate : 12
.  .  .  |  - nReturned : 627
.  .  .  |  - docsExamined : 627
.  .  .  +--OR
.  .  .  .  |  - executionTimeMillisEstimate : 12
.  .  .  .  |  - nReturned : 627
.  .  .  .  +--FETCH
.  .  .  .  .  |  - executionTimeMillisEstimate : 12
.  .  .  .  .  |  - nReturned : 36
.  .  .  .  .  |  - docsExamined : 36
.  .  .  .  .  +--IXSCAN
.  .  .  .  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  .  .  .  |  - nReturned : 36
.  .  .  .  .  .  |  - keysExamined : 39
.  .  .  .  .  .  |  - index used : tags.name_1_tags.seq_1_dt_1
.  .  .  .  +--FETCH
.  .  .  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  .  .  |  - nReturned : 549
.  .  .  .  .  |  - docsExamined : 549
.  .  .  .  .  +--IXSCAN
.  .  .  .  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  .  .  .  |  - nReturned : 549
.  .  .  .  .  .  |  - keysExamined : 550
.  .  .  .  .  .  |  - index used : tags.name_1_tags.seq_1_dt_1
.  .  .  .  +--IXSCAN
.  .  .  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  .  .  |  - nReturned : 103
.  .  .  .  .  |  - keysExamined : 103
.  .  .  .  .  |  - index used : rand_1_dt_1
```

#### 3.3. Simplify Query by Combining Fields
Add a field call name_seq as a combined value of `name` and `seq` as

```
db.forms.find().forEach(function(doc) {
  ns = null;
  if(doc.tags[0].name != null) 
    ns = doc.tags[0].name;
  else if(doc.tags[0].name == null && doc.tags[0].seq != null) 
    ns = "null-" + doc.tags[0].seq;
      
  if(ns == null)
  	doc.name_seq = "null";
  else
  	doc.name_seq = [ns];
  	
  db.forms.save(doc);
});

db.forms.createIndex({ name_seq: 1, dt: -1 });
```

The number of sub-queries is reduced to 2 as follows:

```
db.forms.find( {
  $or: [
    { rand: 5 },
    { name_seq: { $in: [ 
        "AAA", "ABC", "BBB", 
        "null-123", "null-345", "null-789"
       ] }
    }
  ]
}).sort({dt: -1});

```

The above changes allow `mongod` utilize `SORT_MERGE` stage.

```
-- FILTER --
{
   "$or": [
      {
         "rand": {
            "$eq": 5
         }
      },
      {
         "name_seq": {
            "$in": [
               "AAA",
               "ABC",
               "BBB",
               "null-123",
               "null-345",
               "null-789"
            ]
         }
      }
   ]
}

-- SUMMARY --
executionTimeMillis : 3
nReturned : 627
totalKeysExamined : 688
totalDocsExamined : 627

-- STAGES --
SUBPLAN
|  - executionTimeMillisEstimate : 0
|  - nReturned : 627
+--FETCH
.  |  - executionTimeMillisEstimate : 0
.  |  - nReturned : 627
.  |  - docsExamined : 627
.  +--SORT_MERGE
.  .  |  - executionTimeMillisEstimate : 0
.  .  |  - nReturned : 627
.  .  +--IXSCAN
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 103
.  .  .  |  - keysExamined : 103
.  .  .  |  - index used : rand_1_dt_1
.  .  +--IXSCAN
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 12
.  .  .  |  - keysExamined : 12
.  .  .  |  - index used : name_seq_1_dt_1
.  .  +--IXSCAN
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 12
.  .  .  |  - keysExamined : 12
.  .  .  |  - index used : name_seq_1_dt_1
.  .  +--IXSCAN
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 12
.  .  .  |  - keysExamined : 12
.  .  .  |  - index used : name_seq_1_dt_1
.  .  +--IXSCAN
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 183
.  .  .  |  - keysExamined : 183
.  .  .  |  - index used : name_seq_1_dt_1
.  .  +--IXSCAN
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 183
.  .  .  |  - keysExamined : 183
.  .  .  |  - index used : name_seq_1_dt_1
.  .  +--IXSCAN
.  .  .  |  - executionTimeMillisEstimate : 0
.  .  .  |  - nReturned : 183
.  .  .  |  - keysExamined : 183
.  .  .  |  - index used : name_seq_1_dt_1
```

#### 3.4. Improvement
We can see the improvment when `SORT_MERGE` is used vs. `SORT`.

| stage | time (ms) | # returned | keys examined | docs examined |
| --- | ---: | ---: | ---: | ---: |
| OR & SORT | 12 | 627 | 692 | 1,212 |
| SORT_MERGE | 3 | 627 | 688 | 627 |



