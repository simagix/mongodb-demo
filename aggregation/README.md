# Aggregation Framework 
Given a array of document as below, we want to display all sub documents whose value of `favoritesList.book` is "Journey to the West".

```
{
...
	"favoritesList" : [
		{
			"sport" : "Ski",
			"music" : "Easy Listening",
			"city" : "Istanbul",
			"book" : "Moby Dick",
			"movie" : "The Wizard of Oz"
		},
		{
			"book" : "Don Quixote",
			"movie" : "Casablanca",
			"sport" : "Mountaineering",
			"music" : "Soul",
			"city" : "Bangkok"
		},
		{
			"movie" : "Gone with the Wind",
			"sport" : "Baseball",
			"music" : "Blues",
			"city" : "Taipei",
			"book" : "Journey to the West"
		}
	],
...
}
```

We can use the `find()` command, but first let's use *keyhole* to seed randomized documents.

```
keyhole --uri mongodb://localhost/examples --seed --drop --total 100000
```

and apply index.

```
mongo mongodb://localhost/examples
> db.favorites.createIndex({ "favoritesList.book": 1 })
```

## Find
We can use `$elemMatch` to query.

```
db.favorites.explain("executionStats").find(
    {
        favoritesList: {$elemMatch: {book: "Journey to the West"} }
    }, {
        _id: 0, 
        "favoritesList.$": 1
    }
)

"executionTimeMillis" : 271
```

However, because we specify a single query predicate in the `$elemMatch` expression, `$elemMatch` is not necessary.  The commands below are as good as the above command.

```
db.favorites.explain("executionStats").find(
    {
        "favoritesList.book": "Journey to the West"
    }, {
        _id: 0, 
        "favoritesList.$": 1
    }
)

"executionTimeMillis" : 265
```

```
db.favorites.explain("executionStats").find(
    {
        "favoritesList.book": "Journey to the West"
    }, {
        _id: 0, 
        favoritesList: {$elemMatch: {book: "Journey to the West"} }
    } 
)

"executionTimeMillis" : 289
```

But, what if there are multiple matched document in the array and we want to list them as single document, we have to use the aggregation framework.

## Aggregation

### `$match`
The commands below, `$match` again after `$unwind`, solve the problems `find()` cannot.

```
db.favorites.explain("executionStats").aggregate([
  {
    $match: {
      "favoritesList.book": "Journey to the West"
    }
  }, {
    $project: {
      _id: 0, 
      favoritesList: 1
    }
  }, {
    $unwind: {
      path: '$favoritesList'
    }
  }, {
    $match: {
      'favoritesList.book': 'Journey to the West'
    }
  }
])

"executionTimeMillis" : 530
```

### `$redact`
Operator [`$redact`](https://docs.mongodb.com/manual/reference/operator/aggregation/redact/), introduced in 2.6, restricts the contents of the documents based on information stored in the documents themselves.

```
db.favorites.explain("executionStats").aggregate([
  {
    $match: {
      "favoritesList.book": "Journey to the West"
    }
  }, {
    $project: {
      _id: 0, 
      favoritesList: 1
    }
  }, {
    $redact: {
      $cond: {
        'if': {
          $or: [
            {
              $eq: ['$book', 'Journey to the West']
            }, {
              $not: '$book'
            }
          ]
        },
        then: '$$DESCEND', 
        'else': '$$PRUNE'
      }
    }
  }, {
    $unwind: {
      path: '$favoritesList'
    }
  }
])

"executionTimeMillis" : 551
```

### `$filter`
Operator [`$filter`](https://docs.mongodb.com/manual/reference/operator/aggregation/filter/), introduced in 3.2, selects a subset of an array to return based on the specified condition. Returns an array with only those elements that match the condition. The returned elements are in the original order.

```
db.favorites.explain("executionStats").aggregate( [
  {
    $match: {
      "favoritesList.book": "Journey to the West"
    }
  }, {
    $project: {
      favoritesList: {
        $filter: {
          input: '$favoritesList', 
          as: 'favorite', 
          cond: {
            $eq: ['$$favorite.book', 'Journey to the West']
          }
        }
      }, 
      _id: 0
    }
  }, {
    $unwind: {
      path: '$favoritesList'
    }
  }
])

"executionTimeMillis" : 457
```
