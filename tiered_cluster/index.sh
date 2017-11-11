mongo --port 27020 --eval 'db.logs.createIndex({"dc": 1, "host": 1, "dt": 1})' archive
mongo --port 27021 --eval 'db.logs.createIndex({"dc": 1, "host": 1, "dt": 1})' archive
mongo --port 27020 --eval 'db.logs.createIndex({"dc": 1, "stats.src": 1, "stats.pct": 1})' archive
mongo --port 27021 --eval 'db.logs.createIndex({"dc": 1, "stats.src": 1, "stats.pct": 1})' archive
