#! /bin/bash
if [[ -f env ]]; then
    source env
fi

cd src
echo "testing with mysql-connector-java-5.1.49.jar"
export CLASSPATH=.:../lib/mysql-connector-java-5.1.49.jar ; $JAVA_HOME/bin/javac MySQLConn.java
$JAVA_HOME/bin/java -Djdk.tls.client.protocols=TLSv1.2 MySQLConn $bi_uri $bi_user $bi_password
rm -f MySQLConn.class

echo
echo "testing with mysql-connector-java-8.0.22.jar"
export CLASSPATH=.:../lib/mysql-connector-java-8.0.22.jar ; $JAVA_HOME/bin/javac MySQLConn.java
$JAVA_HOME/bin/java -Djdk.tls.client.protocols=TLSv1.2 MySQLConn $bi_uri $bi_user $bi_password
rm -f MySQLConn.class
cd -