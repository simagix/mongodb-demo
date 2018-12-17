# MongoDB Spring Boot Example

## Eclipse

```
gradlew eclipse
```

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
```
./gradlew bootRun


  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.0.6.RELEASE)

 2018-12-17 09:18:26.829  INFO 53354 --- [           main] dealer.Application                       : Starting Application on Kens-MBP with PID 53354 (/Users/kenchen/github/simagix/mongodb-demo/spring-boot/build/classes/java/main started by kenchen in /Users/kenchen/github/simagix/mongodb-demo/spring-boot)
 2018-12-17 09:18:26.833 DEBUG 53354 --- [           main] dealer.Application                       : Running with Spring Boot v2.0.6.RELEASE, Spring v5.0.10.RELEASE
 2018-12-17 09:18:26.833  INFO 53354 --- [           main] dealer.Application                       : No active profile set, falling back to default profiles: default
 2018-12-17 09:18:27.972 DEBUG 53354 --- [           main] .m.c.i.MongoPersistentEntityIndexCreator : Analyzing class class dealer.Vehicle for index information.
 2018-12-17 09:18:28.332  INFO 53354 --- [           main] dealer.Application                       : Started Application in 1.844 seconds (JVM running for 2.177)
 2018-12-17 09:18:28.335  INFO 53354 --- [           main] dealer.Application                       : Use database keyhole
 2018-12-17 09:18:28.363  INFO 53354 --- [           main] dealer.Application                       : Collection exists? true
 2018-12-17 09:18:28.381  INFO 53354 --- [           main] dealer.Application                       : Total # of vehicles: 1000
 2018-12-17 09:18:28.407 DEBUG 53354 --- [           main] o.s.d.m.r.query.MongoQueryCreator        : Created query Query: { "color" : "Red" }, Fields: { }, Sort: { }
 2018-12-17 09:18:28.417 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "color" : "Red" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
 2018-12-17 09:18:28.452  INFO 53354 --- [           main] dealer.Application                       : Total # of red vehicles: 71
 2018-12-17 09:18:28.453 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "color" : "Red" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
 2018-12-17 09:18:28.465  INFO 53354 --- [           main] dealer.Application                       : Total # of red vehicles: 71
 2018-12-17 09:18:28.466 DEBUG 53354 --- [           main] o.s.d.m.r.query.MongoQueryCreator        : Created query Query: { "color" : "Red", "style" : "Truck" }, Fields: { }, Sort: { }
 2018-12-17 09:18:28.467 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "color" : "Red", "style" : "Truck" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
 2018-12-17 09:18:28.472  INFO 53354 --- [           main] dealer.Application                       : Total # of red trucks: 15
 2018-12-17 09:18:28.473 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "$and" : [{ "color" : "Red" }, { "style" : "Truck" }] } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
 2018-12-17 09:18:28.478  INFO 53354 --- [           main] dealer.Application                       : Total # of red trucks: 15
 2018-12-17 09:18:28.489 DEBUG 53354 --- [           main] o.s.d.m.r.query.StringBasedMongoQuery    : Created query Document{{color=Red, style=Truck}} for Document{{}} fields.
 2018-12-17 09:18:28.490 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "color" : "Red", "style" : "Truck" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
 2018-12-17 09:18:28.496  INFO 53354 --- [           main] dealer.Application                       : Vehicle[id=5c158324500e08f008906f7f, color='Red', style='Truck', used='true']
 2018-12-17 09:18:28.496  INFO 53354 --- [           main] dealer.Application                       : Vehicle[id=5c158324500e08f008906f9b, color='Red', style='Truck', used='true']
 2018-12-17 09:18:28.496  INFO 53354 --- [           main] dealer.Application                       : Vehicle[id=5c158324500e08f008907007, color='Red', style='Truck', used='true']
 2018-12-17 09:18:28.499 DEBUG 53354 --- [           main] o.s.d.m.r.query.StringBasedMongoQuery    : Created query Document{{color=Red, used=false}} for Document{{}} fields.
 2018-12-17 09:18:28.500 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "color" : "Red", "used" : false } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
 2018-12-17 09:18:28.510  INFO 53354 --- [           main] dealer.Application                       : Convertible
 2018-12-17 09:18:28.514 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : Inserting Document containing fields: [color, style, used] in collection: cars
 2018-12-17 09:18:28.528 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "style" : "Monster Truck" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
 2018-12-17 09:18:28.531  INFO 53354 --- [           main] dealer.Application                       : Black
 2018-12-17 09:18:28.534 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : Remove using query: { "style" : "Monster Truck" } in collection: cars.
 2018-12-17 09:18:28.538 DEBUG 53354 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "style" : "Monster Truck" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
 2018-12-17 09:18:28.540  INFO 53354 --- [           main] dealer.Application                       : Total # of monster trucks: 0
```
