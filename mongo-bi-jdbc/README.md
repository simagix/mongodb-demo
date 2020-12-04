# Atlas BI JDBC Connection
Connect to Atlas BI Connector using JDBC.

## Test

```bash
# export bi_uri="jdbc:mysql://cluster-biconnector.jgtm2.mongodb.net:27015?useSSL=true"
# export bi_user="user?source=admin"
# export bi_password="password"
./test.sh
```

## Notes

### Atlas

TLS v1.2 didn't work at this writing.  Use TLS v1.1 above in the Atlas configuration.

### JDK Tested

- "Amazon Corretto 15"    
- "OpenJDK 15"    
- "Amazon Corretto 11"    
- "Java SE 11.0.9"        
- "OpenJDK 11.0.2"        
- "Amazon Corretto 8"   

```
% /usr/libexec/java_home --verbose
Matching Java Virtual Machines (6):
    15.0.1, x86_64:     "Amazon Corretto 15"    /Library/Java/JavaVirtualMachines/amazon-corretto-15.jdk/Contents/Home
    15, x86_64: "OpenJDK 15"    /Library/Java/JavaVirtualMachines/jdk-15.jdk/Contents/Home
    11.0.9.1, x86_64:   "Amazon Corretto 11"    /Library/Java/JavaVirtualMachines/amazon-corretto-11.jdk/Contents/Home
    11.0.9, x86_64:     "Java SE 11.0.9"        /Library/Java/JavaVirtualMachines/jdk-11.0.9.jdk/Contents/Home
    11.0.2, x86_64:     "OpenJDK 11.0.2"        /Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home
    1.8.0_275, x86_64:  "Amazon Corretto 8"     /Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
```
 
```bash
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-15.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-15.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-11.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.9.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
```