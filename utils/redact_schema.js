function mask(value) {
    if(typeof value === "string" || value instanceof String) {
        var regEx = /^\d{4}-\d{2}-\d{2}T.*/;
        if(value.match(regEx)) return new Date("2017-09-11T09:00-0500");;
        return "String";
    } else if(typeof value === "number" && isFinite(value)) {
        return 0;
    } else if(typeof value === "boolean") {
        return false;
    } else if(typeof value === "undefined" || value === null) {
        return value;
    } else if(typeof value === "function") {
        return "Function"
    } else {
        return "Unknown";
    }
}

function redact(o) {
    for (var i in o) {
        if(i == "_id") {
            delete o[i];
        } else if (o[i] !== null && typeof(o[i]) == "object") {
            redact(o[i]);
        } else {
            o[i] = mask(o[i]);
        }
    }
}

res = [];
if (typeof database !== 'undefined' && typeof collection !== 'undefined') {
    var doc = db.getSisterDB(database).getCollection(collection).findOne();
    doc = JSON.parse(JSON.stringify(doc));
    redact(doc);
    res = [{"ns": database + "." + collection, "schema": doc}]
} else if (typeof database !== 'undefined' && typeof collection === 'undefined') {
    db.getSisterDB(database).getCollectionNames().forEach(function(c) {
        var doc = db.getSisterDB(database).getCollection(c).findOne();
        doc = JSON.parse(JSON.stringify(doc));
        redact(doc);
        res.push({"ns": database + "." + c, "schema": doc});
    });
} else {    // list all collections redacted schema except admin, local and test
    db.adminCommand( { listDatabases: 1, nameOnly: true} ).databases.forEach(function(d) {
        database = d.name;
        if(["admin", "local", "test"].indexOf(database) < 0) {
            db.getSisterDB(database).getCollectionNames().forEach(function(c) {
                var doc = db.getSisterDB(database).getCollection(c).findOne();
                doc = JSON.parse(JSON.stringify(doc));
                redact(doc);
                res.push({"ns": database + "." + c, "schema": doc});
            });
        }
    });
}
printjson(res);
