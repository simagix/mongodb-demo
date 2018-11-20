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

2018-11-20 09:04:22.953  INFO 84513 --- [           main] dealer.Application                       : Starting Application on Kens-MBP with PID 84513 (/Users/kenchen/github/simagix/mongodb-demo/spring-boot/build/classes/java/main started by kenchen in /Users/kenchen/github/simagix/mongodb-demo/spring-boot)
2018-11-20 09:04:22.956 DEBUG 84513 --- [           main] dealer.Application                       : Running with Spring Boot v2.0.6.RELEASE, Spring v5.0.10.RELEASE
2018-11-20 09:04:22.957  INFO 84513 --- [           main] dealer.Application                       : No active profile set, falling back to default profiles: default
2018-11-20 09:04:23.852 DEBUG 84513 --- [           main] .m.c.i.MongoPersistentEntityIndexCreator : Analyzing class class dealer.Vehicle for index information.
2018-11-20 09:04:24.071  INFO 84513 --- [           main] dealer.Application                       : Started Application in 1.421 seconds (JVM running for 1.756)
2018-11-20 09:04:24.074  INFO 84513 --- [           main] dealer.Application                       : Use database keyhole
2018-11-20 09:04:24.101  INFO 84513 --- [           main] dealer.Application                       : Collection exists? true
2018-11-20 09:04:24.116  INFO 84513 --- [           main] dealer.Application                       : Total # of vehicles: 100000
2018-11-20 09:04:24.137 DEBUG 84513 --- [           main] o.s.d.m.r.query.MongoQueryCreator        : Created query Query: { "color" : "Red" }, Fields: { }, Sort: { }
2018-11-20 09:04:24.146 DEBUG 84513 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "color" : "Red" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
2018-11-20 09:04:24.373  INFO 84513 --- [           main] dealer.Application                       : Total # of red vehicles: 7306
2018-11-20 09:04:24.374 DEBUG 84513 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "color" : "Red" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
2018-11-20 09:04:24.482  INFO 84513 --- [           main] dealer.Application                       : Total # of red vehicles: 7306
2018-11-20 09:04:24.483 DEBUG 84513 --- [           main] o.s.d.m.r.query.MongoQueryCreator        : Created query Query: { "color" : "Red", "style" : "Truck" }, Fields: { }, Sort: { }
2018-11-20 09:04:24.483 DEBUG 84513 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "color" : "Red", "style" : "Truck" } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
2018-11-20 09:04:24.545  INFO 84513 --- [           main] dealer.Application                       : Total # of red trucks: 1196
2018-11-20 09:04:24.547 DEBUG 84513 --- [           main] o.s.data.mongodb.core.MongoTemplate      : find using query: { "$and" : [{ "color" : "Red" }, { "style" : "Truck" }] } fields: Document{{}} for class: class dealer.Vehicle in collection: cars
2018-11-20 09:04:24.603  INFO 84513 --- [           main] dealer.Application                       : Total # of red trucks: 1196
```