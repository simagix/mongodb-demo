/**
 * change_stream.js
 * Author: Ken Chen
 */
var ascoltatori = require('ascoltatori');

const MongoClient = require("mongodb").MongoClient;
const assert = require("assert");

const pipeline = [
];

settings = {
    type: 'mqtt',
    json: false,
    mqtt: require('mqtt'),
    url: 'mqtt://test.mosquitto.org:1883'
};

ascoltatori.build(settings, function (err, ascoltatore) {
    MongoClient.connect("mongodb://localhost:27017/test?replicaSet=replset")
        .then(client => {
            console.log("Connected to server");
            const db = client.db("orders");
            const collection = db.collection("products");
            const changeStream = collection.watch(pipeline);
    
            changeStream.on("change", function(change) {
                payload = JSON.stringify({_id: change.documentKey._id, op: change.operationType, lang: "node.js"});
                console.log(payload);
                ascoltatore.publish('simagix/cs/test', payload, function() {
            });
        }); })
        .catch(err => {
        console.error(err);
    });
});

