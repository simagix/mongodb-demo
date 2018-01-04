mkdir -p certs
cd certs
openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-cert.crt -keyout mongodb-cert.key -config <(
cat <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = x509
x509_extensions = v3_req
# req_extensions = v3_req
distinguished_name = dn

[dn]
C=US
ST=Georgia
L=Atlanta
O=MongoDB
OU=CE
emailAddress=ken.chen@mongodb.com
CN = www.mongodb.com

[v3_req]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:TRUE
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = ip-172-31-62-119.ec2.internal
DNS.3 = ip-172-31-49-218.ec2.internal
DNS.4 = ip-172-31-57-167.ec2.internal
DNS.5 = ec2-52-91-1-1.compute-1.amazonaws.com 
DNS.6 = ec2-54-210-2-2.compute-1.amazonaws.com 
DNS.7 = ec2-54-157-3-3.compute-1.amazonaws.com
EOF
)
