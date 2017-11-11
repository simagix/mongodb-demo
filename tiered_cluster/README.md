## MongoDB Tiered Cluster
- [Tiered Cluster Overview](#id-tier-cluster)
- [Project Description](#id-project-descr)
- [Data Zones and Distribution](#id-data-dist)

<div id='id-tier-cluster'/>

### Tier Cluster Overview
MongoDB is commonly used as a high-performance system at scale to store logs and also to serve as a big-data analytics data store.  Indexes are often applied to achieve better data retrieval performance.  However, the overhead from additional indexes slows down log insertions because indexes have to be updated for all log insertions.  With the growing number of indexes impacting the logs insertion performance, developers begin to archive historical data to another MongoDB cluster for data analytics purpose.  The idea is to separate historical data from operational one into its own cluster.  Often, such data rolling operations are done in customer applications.

Another possible solution is to implement rolling collections, for example daily rolling collections.  In such implementations, logs are inserted into today’s collection, and this ensures better performance because of the expectedly limited size of data of a day and minimum number of indexes.  The disadvantage of having this solution are the extra overheads to create additional indexes after a collection is rolled and applications have to be aware of the names and the number of collections they access.

In this report, we will discuss a solution using MongoDB’s zones to keep both operational and historical data in the same cluster but different shards.  In a sharded cluster, MongoDB provides functionalities to create zones that represent a group of shards and associate ranges of shard key values to that zone.  With the zone feature, we can easily keep historical data in designated shards and add additional indexes to those shards.  On the other hand, logs are only inserted into shards having limited number of indexes.  Moving data from the operational data shards to historical data shards is as simple as updating tag ranges of shards.

<div id='id-project-descr'/>

### Project Description
In this project, we will demo a few MongoDB features, and they are pre-splitting chunks, chunks moves among shards, and creating zones (or tag ranges).  Moreover, we will use Compass to review execution stats of a number of queries.  The demo cluster has four shards residing in three data centers, and they are New York (NYC), San Francisco (SFO), and Atlanta (ATL), respectively.  The NYC and SFO shards are used to store new logs, and, on the other hand, ATL has two shards to host historical data.

#### Cluster Creation
To simulate a four-shard cluster, we use mlaunch to initialize the cluster, and the command below spins up four standnalone mongod servers, one config server, and one mongos router.  All processes are running on the localhost.  Note that in a production environment, each mongod server is replaced by a replica set.

```
$ mlaunch init --sharded 4 --single --mongos 1 --dir cluster --hostname localhost
launching: mongod on port 27018
launching: mongod on port 27019
launching: mongod on port 27020
launching: mongod on port 27021
launching: config server on port 27022
replica set 'configRepl' initialized.
launching: mongos on port 27017
adding shards.
$ 
```

#### Shard Collection
After spinning up the cluster, we create zones use the archive.js script.

```
$ mongo --shell archive.js
MongoDB shell version v3.4.9
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 3.4.9
mongos>
```

Upon executing the above command, the following commands are executed to create zones.

```
sh.addShardTag("shard01", "NYC")
sh.addShardTag("shard02", "SFO")
sh.addShardTag("shard03", "ATL")
sh.addShardTag("shard04", "ATL")
```

Use sh.status() command to display the shards status and you’ll notice the tags info is as follows:

```
 shards:
	{  "_id" : "shard01",  "host" : "localhost:27018",  "state" : 1,  "tags" : [ "NYC" ] }
	{  "_id" : "shard02",  "host" : "localhost:27019",  "state" : 1,  "tags" : [ "SFO" ] }
	{  "_id" : "shard03",  "host" : "localhost:27020",  "state" : 1,  "tags" : [ "ATL" ] }
	{  "_id" : "shard04",  "host" : "localhost:27021",  "state" : 1,  "tags" : [ "ATL" ] }
```

We are ready to enable sharding on database archive and to shard the collection logs.  The shard key of the collection logs is { "dc" : 1, "dt" : 1 }, where dc represents a data center and dt is a date object.

```
mongos> sh.status()
…
  databases:
	{  "_id" : "archive",  "primary" : "shard01",  "partitioned" : true }
		archive.logs
			shard key: { "dc" : 1, "dt" : 1 }
			unique: false
			balancing: true
			chunks:
				shard01	1
			{ "dc" : { "$minKey" : 1 }, "dt" : { "$minKey" : 1 } } -->> { "dc" : { "$maxKey" : 1 }, "dt" : { "$maxKey" : 1 } } on : shard01 Timestamp(1, 0)
```

#### Zones Creation
We are now ready to create zones by adding tag ranges to the shards.  Any data before UTC midnight today is considered historical data and thus belongs to the ATL zone.  Use the command createZones() to create Zones, and use sh.status() to review the status.  You’ll notice chunks, tag ranges, and tags are all changed, examples as below.

```
mongos> createZones()
createZones(): Fri Oct 13 2017 20:00:00 GMT-0400 (EDT)
mongos> sh.status()
…
chunks:
    shard01 3
    shard02 2
    shard03 1
    shard04 1
{ "dc" : { "$minKey" : 1 }, "dt" : { "$minKey" : 1 } } -->> { "dc" : "NYC", "dt" : { "$minKey" : 1 } } on : shard02 Timestamp(5, 0)
{ "dc" : "NYC", "dt" : { "$minKey" : 1 } } -->> { "dc" : "NYC", "dt" : ISODate("2017-10-14T00:00:00Z") } on : shard03 Timestamp(2, 0)
{ "dc" : "NYC", "dt" : ISODate("2017-10-14T00:00:00Z") } -->> { "dc" : "NYC", "dt" : { "$maxKey" : 1 } } on : shard01 Timestamp(5, 1)
{ "dc" : "NYC", "dt" : { "$maxKey" : 1 } } -->> { "dc" : "SFO", "dt" : { "$minKey" : 1 } } on : shard01 Timestamp(1, 4)
{ "dc" : "SFO", "dt" : { "$minKey" : 1 } } -->> { "dc" : "SFO", "dt" : ISODate("2017-10-14T00:00:00Z") } on : shard04 Timestamp(3, 0)
{ "dc" : "SFO", "dt" : ISODate("2017-10-14T00:00:00Z") } -->> { "dc" : "SFO", "dt" : { "$maxKey" : 1 } } on : shard02 Timestamp(4, 0)
{ "dc" : "SFO", "dt" : { "$maxKey" : 1 } } -->> { "dc" : { "$maxKey" : 1 }, "dt" : { "$maxKey" : 1 } } on : shard01 Timestamp(1, 7)
 tag: ATL  { "dc" : "NYC", "dt" : { "$minKey" : 1 } } -->> { "dc" : "NYC", "dt" : ISODate("2017-10-14T00:00:00Z") }
 tag: NYC  { "dc" : "NYC", "dt" : ISODate("2017-10-14T00:00:00Z") } -->> { "dc" : "NYC", "dt" : { "$maxKey" : 1 } }
 tag: ATL  { "dc" : "SFO", "dt" : { "$minKey" : 1 } } -->> { "dc" : "SFO", "dt" : ISODate("2017-10-14T00:00:00Z") }
 tag: SFO  { "dc" : "SFO", "dt" : ISODate("2017-10-14T00:00:00Z") } -->> { "dc" : "SFO", "dt" : { "$maxKey" : 1 } }
```

#### Pre-split Chunks

Pre-splitting chunks is a technique often used to ensure even distribution among shards to prevent unnecessary chunks movements.  The preSplit() command demos how chunks can be pre-splitted.

```
mongos> preSplit()
presplit before: Sat Sep 30 2017 20:00:00 GMT-0400 (EDT) for 48 hours.
presplit before: Sat Oct 14 2017 20:00:00 GMT-0400 (EDT) for 24 hours.
mongos> sh.status()
...
chunks:
    shard01 27
    shard02 26
    shard03 49
    shard04 49
too many chunks to print, use verbose if you want to force print
 tag: ATL  { "dc" : "NYC", "dt" : { "$minKey" : 1 } } -->> { "dc" : "NYC", "dt" : ISODate("2017-10-14T00:00:00Z") }
 tag: NYC  { "dc" : "NYC", "dt" : ISODate("2017-10-14T00:00:00Z") } -->> { "dc" : "NYC", "dt" : { "$maxKey" : 1 } }
 tag: ATL  { "dc" : "SFO", "dt" : { "$minKey" : 1 } } -->> { "dc" : "SFO", "dt" : ISODate("2017-10-14T00:00:00Z") }
 tag: SFO  { "dc" : "SFO", "dt" : ISODate("2017-10-14T00:00:00Z") } -->> { "dc" : "SFO", "dt" : { "$maxKey" : 1 } }
...
```

#### Populate Data

Use insertData() command to populate data to all zones.

```
mongos> insertData()
mongos> db.getSisterDB("archive").logs.stats().count
1440
```

#### Archive Data
The command archive() modifies tag ranges of all three zones and the balancer, if enabled, will move applicable chunks to the ATL zone.

```
mongos> archive()
remove tags: Fri Oct 13 2017 20:00:00 GMT-0400 (EDT)
archive(): Sat Oct 14 2017 00:00:00 GMT-0400 (EDT)
mongos> sh.status()
…
chunks:
    shard01 27
    shard02 26
    shard03 50
    shard04 50
too many chunks to print, use verbose if you want to force print
 tag: ATL  { "dc" : "NYC", "dt" : { "$minKey" : 1 } } -->> { "dc" : "NYC", "dt" : ISODate("2017-10-14T04:00:00Z") }
 tag: NYC  { "dc" : "NYC", "dt" : ISODate("2017-10-14T04:00:00Z") } -->> { "dc" : "NYC", "dt" : { "$maxKey" : 1 } }
 tag: ATL  { "dc" : "SFO", "dt" : { "$minKey" : 1 } } -->> { "dc" : "SFO", "dt" : ISODate("2017-10-14T04:00:00Z") }
 tag: SFO  { "dc" : "SFO", "dt" : ISODate("2017-10-14T04:00:00Z") } -->> { "dc" : "SFO", "dt" : { "$maxKey" : 1 } }
...
```

Note that the chunks distribution and tags are changed.

#### Additional Index on Archive Zone

In this demo, after archiving data, all data before 2017-10-14T04:00:00Z is archived to the ATL zone (shard03 and shard04).  A sample document is as follows:

```
{
	"dc": "NYC",
	"host": "h1.nyc.mongodb.net",
	"dt": ISODate("2017-10-13T00:00:00-0400"),
	"message": "a sample message"
}
```

The ATL zone is for data analytic purpose, and thus an additional index is created on {“dc”: 1, “host”: 1, “dt”: 1}.  Use commands below to apply an index to shard03 and shard04.

```
$ mongo --port 27020 \
  --eval 'db.logs.createIndex({"dc": 1, "host": 1, "dt": 1})' archive
MongoDB shell version v3.4.9
connecting to: mongodb://127.0.0.1:27020/archive
MongoDB server version: 3.4.9
{
	"createdCollectionAutomatically" : false,
	"numIndexesBefore" : 2,
	"numIndexesAfter" : 3,
	"ok" : 1
}
$ mongo --port 27021\
  --eval 'db.logs.createIndex({"dc": 1, "host": 1, "dt": 1})' archive
MongoDB shell version v3.4.9
connecting to: mongodb://127.0.0.1:27021/archive
MongoDB server version: 3.4.9
{
	"createdCollectionAutomatically" : false,
	"numIndexesBefore" : 2,
	"numIndexesAfter" : 3,
	"ok" : 1
}
$
```

This index is NOT visible when connecting to mongos directly.

<div id='id-data-dist'/>

### Data Zones and Distribution
After executing the archive() function, the data tag ranges are as follows:

```
tag: ATL  { "dc" : "NYC", "dt" : { "$minKey" : 1 } }
    -->> { "dc" : "NYC", "dt" : ISODate("2017-10-14T04:00:00Z") }
tag: NYC  { "dc" : "NYC", "dt" : ISODate("2017-10-14T04:00:00Z") }
    -->> { "dc" : "NYC", "dt" : { "$maxKey" : 1 } }
tag: ATL  { "dc" : "SFO", "dt" : { "$minKey" : 1 } }
    -->> { "dc" : "SFO", "dt" : ISODate("2017-10-14T04:00:00Z") }
tag: SFO  { "dc" : "SFO", "dt" : ISODate("2017-10-14T04:00:00Z") }
    -->> { "dc" : "SFO", "dt" : { "$maxKey" : 1 } }

We will use Compass to execute a few queries to observe how MongoDB query engine retrieves data from shards in different stages.
```

#### Query Recent Data
The filter below queries data from shard01 and uses index dc_1_dt_1.

```
{"dc": "NYC", "dt": {$gte: {$date: "2017-10-14T12:00-0400"} } }
```

#### Query Historical Data
The query below queries data from shard03 and shard04 of the ATL zone, and uses index dc_1_host_1_dt_1.

```
{"dc": "NYC", "dt": {$lt: {$date: "2017-10-14T04:00Z"} } }
```

#### Query Historical Data with Host Name
The query below queries data from shard03 and shard04 of the ATL zone, and uses index dc_1_host_1_dt_1.

```
{"dc": "NYC", "dt": {$lt: {$date: "2017-10-14T02:00Z"} }, "host": "h1.nyc.mongodb.net" }
```

#### Query All Shards with Sorting
The query below queries data from all shards.  Note that, for the two shards of ATL zone, each includes two input stages of IXSCAN for NYC and SFO data centers.  The index used on NYC and SFO is dc_1_dt_1, and the index used on ATL is dc_1_host_1_dt_1.

```
FILTER:  {"dc":{$in: ["NYC", "SFO"]},"dt": {$gte: {$date: "2017-09-01T00:00Z"} } }
SORT: {“host”: 1}
```
