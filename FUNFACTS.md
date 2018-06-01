# Fun Facts
### Response time
Q: I have two data centers.  One in Atlanta and the other is in San Francisco.  Is it possible to achieve a 20 milliseconds response time?

```
 _____________________________________________________________________________
/ The shortest distance between Atlanta and San Francisco is 2,140 miles. The \
| speed of light is 186,000 miles per second. Without any resistance,         |
\ mathmetically a round trip will take about 23 milliseconds.                 /
 -----------------------------------------------------------------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/

```

### Storage Size Limit
Q: What is the storage size limit of a shard/replica?

```
 _________________________________________________________________________________
/ There is no limit from mongod, but a pontential limit is from the replication   \
| time. With MongoDB 3.4 or later, wire protocol compression is available,        |
| --networkMessageCompressors, and it is turned on by default in 3.6. If you have |
| 14 TB data and the compressed data storage is 2TB, mathmetically in a           |
| frictionless environment, it will take about 27 hours to perform a full sync    |
\ with a 10GiB switch.                                                            /
 ---------------------------------------------------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

```

| Data Size (TB)|Storage Size (TB)|Wire Compression|Switch (GiB)|Repl Time in Hours|
|---:|---:|---|---:|---:|
|14|2|Yes|10|27.3|
|14|2|No|10|191.1|
|14|2|Yes|1|273.1|
|14|2|No|1|1,911.5|