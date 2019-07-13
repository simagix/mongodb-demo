#! /bin/bash
# Copyright 2019 Kuei-chun Chen. All rights reserved.
: ${REALM:=EXAMPLE.COM}
: ${MASTER_KEY:=MASTER_KEY}
: ${ADMIN_USER:=admin}
: ${ADMIN_PASSWORD:=admin}

# Create database
/usr/sbin/kdb5_util -P $MASTER_KEY -r $REALM create -s

# Create admin user and ACL
kadmin.local -q "addprinc -pw $ADMIN_PASSWORD $ADMIN_USER/admin"
echo "*/admin@$REALM *" > /var/kerberos/krb5kdc/kadm5.acl

# Start Kerberos 5 KDC servers 
mkdir -p /var/log/kerberos
/usr/sbin/krb5kdc -P /var/run/krb5kdc.pid
/usr/sbin/_kadmind -P /var/run/kadmind.pid
tail -F /var/log/kerberos/krb5kdc.log
