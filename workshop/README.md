# MongoDB Workshop

- Installation
- Index
- Aggregation Framework
- View
- Replica
- Security
- X.509
- Sharding
- Performance
- Import/Export

Labs archive was encrypted using [`gpg`](https://www.gnupg.org/)

```
gpg --output labs.gpg --symmetric labs.zip
```

To decrypt

```
curl -L https://github.com/simagix/mongodb-demo/blob/master/workshop/labs.gpg?raw=true > labs.gpg
gpg --output labs.zip --decrypt labs.gpg
```

**Files**

Files in the archive are as follows.

```
labs
├── cars.json
├── certs
│   ├── ca.pem
│   ├── client.pem
│   └── server.pem
├── perf.js
└── workshop-student.pdf
```