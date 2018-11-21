# Mongoose Example

## Test
### Start `mongod`
```
mkdir db
mongod --dbpath db
```

### Seed Data
```
keyhole --seed --drop --total 100000 mongodb://localhost/keyhole
```

### Run
Install dependencies.

```
npm install
```

Test

```
npm test

Mongoose: cars.find({}, { projection: {} })
Mongoose: cars.find({ color: 'Red', style: 'Truck' }, { projection: {} })
Mongoose: cars.find({ color: 'Black', style: 'Monster Truck' }, { projection: {} })
total # of red trucks: 20
total # of black monster trucks: 0
Mongoose: cars.insertOne({ _id: ObjectId("5bf56caf8cf91f51162d68e6"), color: 'Black', style: 'Monster Truck', __v: 0 })
Mongoose: cars.find({ color: 'Black', style: 'Monster Truck' }, { projection: {} })
total # of vehicles: 1001
total # of black monster trucks: 1
Mongoose: cars.deleteOne({ _id: ObjectId("5bf56caf8cf91f51162d68e6") }, { color: 'Black', style: 'Monster Truck' })
```
