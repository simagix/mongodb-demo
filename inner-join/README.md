# MongoDB Aggregation for Inner Join

## Insert data of two collections.

```
use products
db.orders.insert([
   { "_id" : 1, "item" : "almonds", "price" : 12, "quantity" : 2 },
   { "_id" : 2, "item" : "pecans", "price" : 20, "quantity" : 1 },
   { "_id" : 3  }
])
db.inventory.insert([
   { "_id" : 1, "sku" : "almonds", description: "product 1", "instock" : 120 },
   { "_id" : 2, "sku" : "bread", description: "product 2", "instock" : 80 },
   { "_id" : 3, "sku" : "cashews", description: "product 3", "instock" : 60 },
   { "_id" : 4, "sku" : "pecans", description: "product 4", "instock" : 70 },
   { "_id" : 5, "sku": null, description: "Incomplete" },
   { "_id" : 6 }
])
```

## In the RDBMS world,

```
desc orders;
+----------+----------------+------+-----+---------+-------+
| Field    | Type           | Null | Key | Default | Extra |
+----------+----------------+------+-----+---------+-------+
| _id      | double         | YES  | PRI | null    |       |
| item     | varchar(65535) | YES  |     | null    |       |
| price    | double         | YES  |     | null    |       |
| quantity | double         | YES  |     | null    |       |
+----------+----------------+------+-----+---------+-------+

desc inventory;
+-------------+----------------+------+-----+---------+-------+
| Field       | Type           | Null | Key | Default | Extra |
+-------------+----------------+------+-----+---------+-------+
| _id         | double         | YES  | PRI | null    |       |
| description | varchar(65535) | YES  |     | null    |       |
| instock     | double         | YES  |     | null    |       |
| sku         | varchar(65535) | YES  |     | null    |       |
+-------------+----------------+------+-----+---------+-------+

SELECT o.*, i.description 
    FROM orders o, inventory i 
    WHERE o.item = i.sku;
```

## Use MongoDB aggregation framework.

```
db.orders.aggregate([
    {
        "$match": {
            "item": {
                "$ne": null
            }
        }
    },
    {
        "$lookup": {
            "as": "_inventory",
            "foreignField": "sku",
            "from": "inventory",
            "localField": "item"
        }
    },
    {
        "$unwind": {
            "path": "$_inventory",
            "preserveNullAndEmptyArrays": false
        }
    },
    {
        "$project": {
            "_id": "$_id",
            "description": "$_inventory.description",
            "item": "$item",
            "price": "$price",
            "quantity": "$quantity"
        }
    }
]).pretty()

{
	"_id" : 1,
	"description" : "product 1",
	"item" : "almonds",
	"price" : 12,
	"fquantity" : 2
}
{
	"_id" : 2,
	"description" : "product 4",
	"item" : "pecans",
	"price" : 20,
	"fquantity" : 1
}
```

## Retrieve Only Needed Fiedls
Starting MongoDB 3.6, you can retrieve defined fields, instead of entire document, from another collection.  This will be more efficient to "join".

```
db.orders.aggregate([
    {
        "$match": {
            "item": {
                "$ne": null
            }
        }
    },
    {
        "$lookup": {
            "as": "_inventory",
            "from": "inventory",
            let: {
                item: "$item"
            },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $eq: ["$sku", "$$item"]
                        }
                    },
                },
                {
                    $project: {
                        _id: 0,
                        description: 1
                    }
                }
            ]
        }
    },
    {
        "$unwind": {
            "path": "$_inventory",
            "preserveNullAndEmptyArrays": false
        }
    }, {
        "$project": {
            "_id": "$_id",
            "description": "$_inventory.description",
            "item": "$item",
            "price": "$price",
            "quantity": "$quantity"
        }
    }
]).pretty()

{
	"_id" : 1,
	"description" : "product 1",
	"item" : "almonds",
	"price" : 12,
	"quantity" : 2
}
{
	"_id" : 2,
	"description" : "product 4",
	"item" : "pecans",
	"price" : 20,
	"quantity" : 1
}
```