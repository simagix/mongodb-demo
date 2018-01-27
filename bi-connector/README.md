# BI Connector Example
## 1. Seed Database

```
$ mcheck-osx-x64 -seed
threads: 1
MongoDB URI: mongodb://localhost
seed: true
Populate data under database _MCHECK_
createIndex mongodb://localhost
Ctrl-C to quit...
2018/01/27 13:15:05 INSERT 512 140.248µs 71.807484ms size 1024
```

## 2. Start BI Connector
```
$ mongosqld -vvvv
2018-01-27T13:16:07.700-0500 W MONGOSQLD  logging verbosity level 4 does not exist; setting verbosity to Dev
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten] mongosqld starting: version=v2.4.0-beta1 pid=85483 host=Kens-MBP
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten] git version: ab2e1384546063d70c773f97751fbf9f788e7774
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten] OpenSSL version: OpenSSL 1.0.2l  25 May 2017
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten] options: {systemLog: {verbosity: 4}}
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten]
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten] ** NOTE: This is a development version (v2.4.0-beta1) of mongosqld.
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten] **       Not recommended for production.
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten]
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten] ** WARNING: Access control is not enabled for mongosqld.
2018-01-27T13:16:07.700-0500 I CONTROL    [initandlisten]
2018-01-27T13:16:07.700-0500 I NETWORK    [initandlisten] waiting for connections at 127.0.0.1:3307
2018-01-27T13:16:07.700-0500 I SAMPLER    [schemaDiscovery] sampler running in standalone mode
2018-01-27T13:16:07.700-0500 I NETWORK    [initandlisten] waiting for connections at /tmp/mysql.sock
2018-01-27T13:16:07.700-0500 I SAMPLER    [schemaDiscovery] initializing schema
2018-01-27T13:16:07.706-0500 I SAMPLER    [schemaDiscovery] stored schema not found, sampling instead
2018-01-27T13:16:07.706-0500 I SAMPLER    [schemaDiscovery] sampling MongoDB for schema...
2018-01-27T13:16:07.707-0500 D SAMPLER    [schemaDiscovery] mapping schema for database "_MCHECK_"
2018-01-27T13:16:07.707-0500 D SAMPLER    [schemaDiscovery] mapping schema for namespace "_MCHECK_"."robots"
2018-01-27T13:16:07.719-0500 D SAMPLER    [schemaDiscovery] mapped new table "robots"
2018-01-27T13:16:07.719-0500 D SAMPLER    [schemaDiscovery] finished mapping schema for namespace "_MCHECK_"."robots"
2018-01-27T13:16:07.719-0500 D SAMPLER    [schemaDiscovery] mapping schema for namespace "_MCHECK_"."brands"
2018-01-27T13:16:07.726-0500 D SAMPLER    [schemaDiscovery] mapped new table "brands"
2018-01-27T13:16:07.726-0500 D SAMPLER    [schemaDiscovery] finished mapping schema for namespace "_MCHECK_"."brands"
2018-01-27T13:16:07.726-0500 D SAMPLER    [schemaDiscovery] skipping "admin" database
2018-01-27T13:16:07.726-0500 D SAMPLER    [schemaDiscovery] skipping namespace "config"."system.sessions"
2018-01-27T13:16:07.726-0500 D SAMPLER    [schemaDiscovery] skipping "local" database
2018-01-27T13:16:07.726-0500 I SAMPLER    [schemaDiscovery] mapped schema for 2 namespaces: "_MCHECK_" (2): ["robots", "brands"]
```

## 3. Schema
### 3.1. Collection robots
#### 3.1.1. MongoDB
```
{
	"_id" : ObjectId("5a6cc1a95649543985e7aed6"),
	"name" : "Robot-0",
	"nickname" : "Robot-0",
	"descr" : "description",
	"stats" : {
		"tasked" : 1,
		"battery" : 95,
		"maint" : true
	},
	"updated" : ISODate("2018-01-27T18:15:05.870Z")
}
```

#### 1.3.1.2. MySQL
```
mysql> DESC robots;
+---------------+----------------+------+------+---------+-------+
| Field         | Type           | Null | Key  | Default | Extra |
+---------------+----------------+------+------+---------+-------+
| _id           | varchar(65535) | YES  | PRI  | NULL    |       |
| descr         | varchar(65535) | YES  |      | NULL    |       |
| name          | varchar(65535) | YES  |      | NULL    |       |
| nickname      | varchar(65535) | YES  |      | NULL    |       |
| stats.battery | bigint(20)     | YES  |      | NULL    |       |
| stats.maint   | tinyint(1)     | YES  |      | NULL    |       |
| stats.tasked  | bigint(20)     | YES  |      | NULL    |       |
| updated       | datetime(6)    | YES  |      | NULL    |       |
+---------------+----------------+------+------+---------+-------+
```

### 3.2. Collection brands
#### 3.2.1. MongoDB
```
{
	"_id" : ObjectId("5a6cc1a95649543985e7b2d6"),
	"name" : "Robot-0",
	"sku" : "DA39A3EE5E6B4B0D3255BFEF95601890AFD80709"
}
```

#### 3.2.2. MySQL
```
mysql> DESC brands;
+-------+----------------+------+------+---------+-------+
| Field | Type           | Null | Key  | Default | Extra |
+-------+----------------+------+------+---------+-------+
| _id   | varchar(65535) | YES  | PRI  | NULL    |       |
| name  | varchar(65535) | YES  |      | NULL    |       |
| sku   | varchar(65535) | YES  |      | NULL    |       |
+-------+----------------+------+------+---------+-------+
```

## 4. Join
### 4.1. SQL
```
mysql> SELECT a.nickname, a.`stats.tasked`,  a.`stats.battery`, b.sku
    -> FROM robots a, brands b WHERE a.name = b.name AND a.`stats.battery` < 25
    -> ORDER BY a.nickname LIMIT 5;
+-----------+--------------+---------------+------------------------------------------+
| nickname  | stats.tasked | stats.battery | sku                                      |
+-----------+--------------+---------------+------------------------------------------+
| Robot-103 |           17 |            15 | DA39A3EE5E6B4B0D3255BFEF95601890AFD80709 |
| Robot-110 |           18 |            10 | DA39A3EE5E6B4B0D3255BFEF95601890AFD80709 |
| Robot-115 |           17 |            15 | DA39A3EE5E6B4B0D3255BFEF95601890AFD80709 |
| Robot-117 |           17 |            15 | DA39A3EE5E6B4B0D3255BFEF95601890AFD80709 |
| Robot-123 |           19 |             5 | DA39A3EE5E6B4B0D3255BFEF95601890AFD80709 |
+-----------+--------------+---------------+------------------------------------------+
5 rows in set (0.02 sec)
```

### 4.2. BI Connector 
#### 4.2.1. SQL to Aggregation Framework Mapping
```
2018-01-27T13:55:31.194-0500 I ALGEBRIZER [conn1] generating query plan for sql:

"
SELECT a.nickname, a.`stats.tasked`,  a.`stats.battery`,  b.sku 
    FROM robots a, brands b 
    WHERE a.name = b.name AND a.`stats.battery` < 25 
    ORDER BY a.nickname LIMIT 5
"

2018-01-27T13:55:31.195-0500 D EXECUTOR   [conn1] executing query plan:
↳ MongoSource: '[robots brands]' (db: '_MCHECK_', collection: '[robots brands]') as '[a b]':

	{"$match":{"stats.battery":{"$lt":{"$numberLong":"25"}}}},
	{"$match":{"name":{"$ne":null}}},
	{"$lookup":{"as":"__joined_b","foreignField":"name","from":"brands","localField":"name"}},
	{"$unwind":{"path":"$__joined_b","preserveNullAndEmptyArrays":false}},
	{"$sort":{"nickname":1}},
	{"$limit":{"$numberLong":"5"}},
	{"$project":{
	   "_MCHECK__DOT_a_DOT_nickname":"$nickname",
	   "_MCHECK__DOT_a_DOT_stats_DOT_battery":"$stats.battery",
	   "_MCHECK__DOT_a_DOT_stats_DOT_tasked":"$stats.tasked",
	   "_MCHECK__DOT_b_DOT_sku":"$__joined_b.sku"}}

```
	
#### 4.2.2. Detail Logs
```
2018-01-27T13:51:02.197-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:02.197-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:02.197-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:02.197-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:02.197-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:02.198-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:02.198-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:02.198-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:02.198-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:02.198-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:02.198-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:02.205-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:05.225-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:05.225-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:05.225-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:05.225-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:05.225-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:05.226-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:05.226-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:05.226-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:05.226-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:05.226-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:05.226-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:05.232-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:08.256-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:08.256-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:08.256-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:08.256-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:08.256-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:08.256-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:08.256-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:08.256-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:08.256-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:08.256-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:08.256-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:08.263-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:11.295-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:11.295-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:11.295-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:11.295-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:11.295-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:11.295-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:11.295-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:11.295-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:11.295-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:11.295-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:11.295-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:11.302-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:15.765-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:15.765-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:15.765-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:15.765-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:15.765-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:15.765-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:15.765-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:15.765-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:15.765-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:15.765-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:15.765-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:15.771-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:18.796-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:18.796-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:18.796-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:18.796-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:18.796-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:18.796-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:18.796-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:18.796-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:18.796-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:18.796-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:18.796-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:18.804-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:19.671-0500 I NETWORK    [conn9] parsing "SELECT a.nickname, a.`stats.tasked`,  a.`stats.battery`,  b.sku FROM robots a, brands b WHERE a.name = b.name AND a.`stats.battery` < 25 ORDER BY a.nickname LIMIT 5"
2018-01-27T13:51:19.671-0500 I ALGEBRIZER [conn9] generating query plan for sql: "SELECT a.nickname, a.`stats.tasked`,  a.`stats.battery`,  b.sku FROM robots a, brands b WHERE a.name = b.name AND a.`stats.battery` < 25 ORDER BY a.nickname LIMIT 5"
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] optimizing query plan:
↳ Project(nickname, stats.tasked, stats.battery, sku):
	↳ Limit(offset: 0, limit: 5):
		↳ OrderBy(_MCHECK_.a.nickname ASC):
			↳ Filter (_MCHECK_.a.name = _MCHECK_.b.name and _MCHECK_.a.stats.battery<25):
				↳ Join:
					↳ MongoSource: '[robots]' (db: '_MCHECK_', collection: '[robots]') as '[a]'		cross join
					↳ MongoSource: '[brands]' (db: '_MCHECK_', collection: '[brands]') as '[b]'		on 1

2018-01-27T13:51:19.671-0500 I OPTIMIZER  [conn9] running optimization stage 'subqueries'
2018-01-27T13:51:19.671-0500 I OPTIMIZER  [conn9] running optimization stage 'evaluations'
2018-01-27T13:51:19.671-0500 I OPTIMIZER  [conn9] running optimization stage 'cross joins'
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] optimized plan after 'cross joins':
↳ Project(nickname, stats.tasked, stats.battery, sku):
	↳ Limit(offset: 0, limit: 5):
		↳ OrderBy(_MCHECK_.a.nickname ASC):
			↳ Filter (_MCHECK_.a.stats.battery<25):
				↳ Join:
					↳ MongoSource: '[robots]' (db: '_MCHECK_', collection: '[robots]') as '[a]'		join
					↳ MongoSource: '[brands]' (db: '_MCHECK_', collection: '[brands]') as '[b]'		on _MCHECK_.a.name = _MCHECK_.b.name

2018-01-27T13:51:19.671-0500 I OPTIMIZER  [conn9] running optimization stage 'inner join'
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] optimized plan after 'inner join':
↳ Project(nickname, stats.tasked, stats.battery, sku):
	↳ Limit(offset: 0, limit: 5):
		↳ OrderBy(_MCHECK_.a.nickname ASC):
			↳ Filter (_MCHECK_.a.stats.battery<25):
				↳ Join:
					↳ MongoSource: '[robots]' (db: '_MCHECK_', collection: '[robots]') as '[a]'		join
					↳ MongoSource: '[brands]' (db: '_MCHECK_', collection: '[brands]') as '[b]'		on _MCHECK_.a.name = _MCHECK_.b.name

2018-01-27T13:51:19.671-0500 I OPTIMIZER  [conn9] running optimization stage 'filtering'
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] optimized plan after 'filtering':
↳ Project(nickname, stats.tasked, stats.battery, sku):
	↳ Limit(offset: 0, limit: 5):
		↳ OrderBy(_MCHECK_.a.nickname ASC):
			↳ Join:
				↳ Filter (_MCHECK_.a.stats.battery<25):
					↳ MongoSource: '[robots]' (db: '_MCHECK_', collection: '[robots]') as '[a]'		join
				↳ MongoSource: '[brands]' (db: '_MCHECK_', collection: '[brands]') as '[b]'			on _MCHECK_.a.name = _MCHECK_.b.name

2018-01-27T13:51:19.671-0500 I OPTIMIZER  [conn9] running optimization stage 'pushdown'
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] attempting to use self-join optimization for tables [a] and [b]
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] cannot use self-join optimization, pipeline has different root tables: robots and brands
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] attempting to translate join stage to lookup
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] successfully translated join stage to lookup
2018-01-27T13:51:19.671-0500 D OPTIMIZER  [conn9] optimized plan after 'pushdown':
↳ MongoSource: '[robots brands]' (db: '_MCHECK_', collection: '[robots brands]') as '[a b]':
	{"$match":{"stats.battery":{"$lt":{"$numberLong":"25"}}}},
	{"$match":{"name":{"$ne":null}}},
	{"$lookup":{"as":"__joined_b","foreignField":"name","from":"brands","localField":"name"}},
	{"$unwind":{"path":"$__joined_b","preserveNullAndEmptyArrays":false}},
	{"$sort":{"nickname":1}},
	{"$limit":{"$numberLong":"5"}},
	{"$project":{"_MCHECK__DOT_a_DOT_nickname":"$nickname","_MCHECK__DOT_a_DOT_stats_DOT_battery":"$stats.battery","_MCHECK__DOT_a_DOT_stats_DOT_tasked":"$stats.tasked","_MCHECK__DOT_b_DOT_sku":"$__joined_b.sku"}}
2018-01-27T13:51:19.671-0500 D EXECUTOR   [conn9] executing query plan:
↳ MongoSource: '[robots brands]' (db: '_MCHECK_', collection: '[robots brands]') as '[a b]':
	{"$match":{"stats.battery":{"$lt":{"$numberLong":"25"}}}},
	{"$match":{"name":{"$ne":null}}},
	{"$lookup":{"as":"__joined_b","foreignField":"name","from":"brands","localField":"name"}},
	{"$unwind":{"path":"$__joined_b","preserveNullAndEmptyArrays":false}},
	{"$sort":{"nickname":1}},
	{"$limit":{"$numberLong":"5"}},
	{"$project":{"_MCHECK__DOT_a_DOT_nickname":"$nickname","_MCHECK__DOT_a_DOT_stats_DOT_battery":"$stats.battery","_MCHECK__DOT_a_DOT_stats_DOT_tasked":"$stats.tasked","_MCHECK__DOT_b_DOT_sku":"$__joined_b.sku"}}
2018-01-27T13:51:19.697-0500 I NETWORK    [conn9] returned 5 rows (304B)
2018-01-27T13:51:19.697-0500 I NETWORK    [conn9] done executing query in 26ms
2018-01-27T13:51:21.843-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:21.843-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:21.843-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:21.843-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:21.843-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:21.843-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:21.843-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:21.843-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:21.843-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:21.843-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:21.843-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:21.850-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:25.405-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:25.405-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:25.405-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:25.405-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:25.405-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:25.405-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:25.405-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:25.405-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:25.405-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:25.405-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:25.406-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:25.413-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:28.434-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:28.434-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:28.435-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:28.435-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:28.435-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:28.435-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:28.435-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:28.435-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:28.435-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:28.435-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:28.435-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:28.442-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:41.463-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:41.463-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:41.463-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:41.463-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:41.463-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:41.463-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:41.463-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:41.463-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:41.463-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:41.463-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:41.463-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:41.470-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:53.267-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:53.267-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:53.267-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:53.267-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:53.267-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:53.267-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:53.267-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:53.267-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:53.267-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:53.267-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:53.267-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:53.276-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:51:56.306-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:51:56.306-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:51:56.306-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:56.306-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:51:56.306-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:51:56.306-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:51:56.306-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:51:56.306-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:51:56.306-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:51:56.306-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:51:56.306-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:51:56.312-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
2018-01-27T13:52:09.319-0500 I NETWORK    [conn7] parsing "SHOW GLOBAL STATUS"
2018-01-27T13:52:09.319-0500 I ALGEBRIZER [conn7] generating query plan for show statement: "SHOW GLOBAL STATUS"
2018-01-27T13:52:09.319-0500 D OPTIMIZER  [conn7] optimizing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:52:09.319-0500 I OPTIMIZER  [conn7] running optimization stage 'subqueries'
2018-01-27T13:52:09.319-0500 I OPTIMIZER  [conn7] running optimization stage 'evaluations'
2018-01-27T13:52:09.319-0500 I OPTIMIZER  [conn7] running optimization stage 'cross joins'
2018-01-27T13:52:09.319-0500 I OPTIMIZER  [conn7] running optimization stage 'inner join'
2018-01-27T13:52:09.319-0500 D OPTIMIZER  [conn7] attempting to optimize inner join in subquery 'GLOBAL_STATUS'
2018-01-27T13:52:09.319-0500 I OPTIMIZER  [conn7] running optimization stage 'filtering'
2018-01-27T13:52:09.319-0500 I OPTIMIZER  [conn7] running optimization stage 'pushdown'
2018-01-27T13:52:09.319-0500 D EXECUTOR   [conn7] executing query plan:
↳ OrderBy(information_schema.GLOBAL_STATUS.Variable_name ASC):
	↳ Subquery(GLOBAL_STATUS):
		↳ Project(Variable_name, Value):
			↳ DynamicSource (GLOBAL_STATUS):

2018-01-27T13:52:09.326-0500 I NETWORK    [conn7] returned 515 rows (14.5KiB)
```