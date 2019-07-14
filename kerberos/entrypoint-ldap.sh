#! /bin/bash
# Copyright 2019 Kuei-chun Chen. All rights reserved.
: ${ADMIN_PASSWORD:=admin}

# Enable TLS
echo "TLS_REQCERT never" >> /etc/openldap/ldap.conf
echo "TLS_CACERT /server.pem" >> /etc/openldap/ldap.conf

# Start slapd
/usr/sbin/slapd -u ldap -h "ldapi:/// ldaps://ldap.simagix.com"
LDAP_LOG=/tmp/ldap.log

olcRootPW=$(slappasswd -h {SSHA} -s $ADMIN_PASSWORD)
echo "olcRootPW: ${olcRootPW}" >> /db.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f /db.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f /monitor.ldif

# Set up LDAP database
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap:ldap /var/lib/ldap/*
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
ldapadd -x -w $ADMIN_PASSWORD -D "cn=ldapadm,dc=simagix,dc=local" -H ldapi:/// -f /base.ldif
ldapadd -x -w $ADMIN_PASSWORD -D "cn=ldapadm,dc=simagix,dc=local" -H ldapi:/// -f /mdb.ldif

touch $LDAP_LOG
tail -F $LDAP_LOG
