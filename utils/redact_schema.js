function mask(value) {
    if(typeof value === "string" || value instanceof String) {
        var regEx = /^\d{4}-\d{2}-\d{2}T.*/;
        if(value.match(regEx)) return "ISODate(...)";
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
        if (o[i] !== null && typeof(o[i]) == "object") {
            redact(o[i]);
        } else {
            o[i] = mask(o[i]);
        }
    }
}

var doc = db.getSisterDB(database).getCollection(collection).findOne();
doc = JSON.parse(JSON.stringify(doc));
redact(doc);
printjson(doc);

