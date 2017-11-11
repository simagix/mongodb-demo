//mlaunch init --sharded 4 --single --mongos 1 --dir cluster --hostname localhost
// { "dc": "NYC", "host": "h1.nyc.mongodb.net", "dt": new Date(), "message": "message" }
// {"dc": "NYC", "dt": {$lte: {$date: "2017-10-13T02:00-0400"} } }
sh.addShardTag("shard01", "NYC")
sh.addShardTag("shard02", "SFO")
sh.addShardTag("shard03", "ATL")
sh.addShardTag("shard04", "ATL")

function help() {
    print("--- HELP ---");
    print("\tinit()");
    print("\tcreateZones()");
    print("\tpreSplit()");
    print("\tinsertData()");
    print("\tarchive()");
}

function initAll() {
    init();
    createZones();
    preSplit();
    insertData();
}

function init() {
    db.getSisterDB("archive").dropDatabase()
    db.getSisterDB("config").tags.remove({ "ns": "archive.logs" });
    sh.enableSharding("archive")
    sh.shardCollection("archive.logs", {"dc": 1, "dt": 1})
}

function createZones() {
	var today = new Date();
    today.setUTCHours(0,0,0,0);
    print("createZones(): " + today);
	sh.addTagRange( "archive.logs", { dc: "NYC", dt: today }, { dc: "NYC", dt: MaxKey }, "NYC")
	sh.addTagRange( "archive.logs", { dc: "SFO", dt: today }, { dc: "SFO", dt: MaxKey }, "SFO")
	sh.addTagRange( "archive.logs", { dc: "NYC", dt: MinKey }, { dc: "NYC", dt: today }, "ATL")
	sh.addTagRange( "archive.logs", { dc: "SFO", dt: MinKey }, { dc: "SFO", dt: today }, "ATL")
}

function preSplit() {
    var day = new Date('2017-10-01T00:00Z');
    var ts = day.getTime();
    var onehour = 60 * 60e3;
    var hours = 48;
    print("presplit before: " + day +  " for " + hours + " hours.");
    for(i = 0; i < hours; i++) { sh.splitAt("archive.logs", {"dc": "NYC", "dt": new Date(ts - i * onehour)} ); }
    for(i = 0; i < hours; i++) { sh.splitAt("archive.logs", {"dc": "SFO", "dt": new Date(ts - i * onehour)} ); }

    hours = 24;
	var today = new Date();
    today.setUTCHours(hours,0,0,0);
    print("presplit before: " + today +  " for " + hours + " hours.");
    var ts = today.getTime();
    for(i = 0; i < hours; i++) { sh.splitAt("archive.logs", {"dc": "NYC", "dt": new Date(ts + i * onehour)} ); }
    for(i = 0; i < hours; i++) { sh.splitAt("archive.logs", {"dc": "SFO", "dt": new Date(ts + i * onehour)} ); }
}

function insertData() {
    var day = new Date('2017-10-01T00:00Z');
    var ts = day.getTime();
    var onehour = 60 * 60e3;
    var mtempl = "message holder for ";
    var hours = 48;
    var host = "";
    var message = "";
    var bulk = db.getSisterDB("archive").logs.initializeUnorderedBulkOp();
    for(i = 0; i < hours; i++) {
        for(m = 0; m < 60; m++) {
            host = "h" + m % 5;
            message = mtempl + host;
            _dt = new Date(ts - i * onehour - m*60e3);
            fqdn = host + ".nyc.mongodb.net";
            stats = [{"pct": Math.round(100*Math.random()), "src": "cpu"}, {"src": "mem", "pct": Math.round(100*Math.random())}]; 
            bulk.insert({ "dc": "NYC", "host": fqdn, "dt": _dt, "message": message, "stats": stats });
            fqdn = host + ".sfo.mongodb.net";
            stats = [{"pct": Math.round(100*Math.random()), "src": "cpu"}, {"src": "mem", "pct": Math.round(100*Math.random())}]; 
            bulk.insert({ "dc": "SFO", "host": fqdn, "dt": _dt, "message": message, "stats": stats });
        }
    }

    hours = 24;
	var today = new Date();
    today.setUTCHours(hours,0,0,0);
    var ts = today.getTime();
    for(i = 0; i < hours; i++) {
        for(m = 0; m < 60; m++) {
            host = "h" + m % 5;
            message = mtempl + host;
            _dt = new Date(ts - i * onehour - m*60e3);
            fqdn = host + ".nyc.mongodb.net";
            stats = [{"pct": Math.round(100*Math.random()), "src": "cpu"}, {"src": "mem", "pct": Math.round(100*Math.random())}]; 
            bulk.insert({ "dc": "NYC", "host": fqdn, "dt": _dt, "message": message, "stats": stats });
            fqdn = host + ".sfo.mongodb.net";
            stats = [{"pct": Math.round(100*Math.random()), "src": "cpu"}, {"src": "mem", "pct": Math.round(100*Math.random())}]; 
            bulk.insert({ "dc": "SFO", "host": fqdn, "dt": _dt, "message": message, "stats": stats });
        }
    }

    bulk.execute()
}

function archive() {
	sh.stopBalancer();
    db.getSisterDB("config").tags.remove({ "ns": "archive.logs" });
//	sh.removeTagRange( "archive.logs", { dc: "NYC", dt: today }, { dc: "NYC", dt: MaxKey }, "NYC")
//	sh.removeTagRange( "archive.logs", { dc: "SFO", dt: today }, { dc: "SFO", dt: MaxKey }, "SFO")
//	sh.removeTagRange( "archive.logs", { dc: "NYC", dt: MinKey }, { dc: "NYC", dt: today }, "ATL")
//	sh.removeTagRange( "archive.logs", { dc: "SFO", dt: MinKey }, { dc: "SFO", dt: today }, "ATL")
	
	var nd = new Date();
	nd.setUTCHours(4,0,0,0);
    print("archive before: " + nd);
	sh.addTagRange( "archive.logs", { dc: "NYC", dt: nd }, { dc: "NYC", dt: MaxKey }, "NYC")
	sh.addTagRange( "archive.logs", { dc: "SFO", dt: nd }, { dc: "SFO", dt: MaxKey }, "SFO")
	sh.addTagRange( "archive.logs", { dc: "NYC", dt: MinKey }, { dc: "NYC", dt: nd }, "ATL")
	sh.addTagRange( "archive.logs", { dc: "SFO", dt: MinKey }, { dc: "SFO", dt: nd }, "ATL")
	sh.startBalancer();
}

help();

