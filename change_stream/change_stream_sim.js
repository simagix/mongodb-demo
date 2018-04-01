var id = "Simagix-" + Math.round(Math.random()*1000000).toString(16);
db.products.remove({ _id: id });
db.products.insert({ _id: id, cost: 1});
db.products.save({ _id: id, cost: 5});
db.products.update({ _id: id }, {$inc: {cost: 3}});
db.products.remove({ _id: id });
