// Copyright 2018 Kuei-chun Chen. All rights reserved.

package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"net"

	"github.com/globalsign/mgo"
	"github.com/globalsign/mgo/bson"
)

func main() {
	uri := "mongodb://user:password@localhost/keyhole?authSource=admin"
	sslCAFile := "/etc/ssl/certs/ca.pem"
	sslPEMKeyFile := "/etc/ssl/certs/client.pem"
	tlsConfig := &tls.Config{}
	// tlsConfig.InsecureSkipVerify = true

	clientCertPEM, _ := ioutil.ReadFile(sslPEMKeyFile)
	clientKeyPEM, _ := ioutil.ReadFile(sslPEMKeyFile)
	clientCert, _ := tls.X509KeyPair(clientCertPEM, clientKeyPEM)
	clientCert.Leaf, _ = x509.ParseCertificate(clientCert.Certificate[0])
	tlsConfig.Certificates = []tls.Certificate{clientCert}

	ca, _ := ioutil.ReadFile(sslCAFile)
	roots := x509.NewCertPool()
	roots.AppendCertsFromPEM(ca)
	tlsConfig.RootCAs = roots

	dialInfo, perr := mgo.ParseURL(uri)
	if perr != nil {
		panic(perr)
	}
	dialInfo.DialServer = func(addr *mgo.ServerAddr) (net.Conn, error) {
		conn, derr := tls.Dial("tcp", addr.String(), tlsConfig)
		if derr != nil {
			panic(derr)
		}
		return conn, derr
	}
	session, derr := mgo.DialWithInfo(dialInfo)
	if derr != nil {
		panic(derr)
	}
	n, cerr := session.DB("keyhole").C("cars").Find(bson.M{"color": "Red"}).Count()
	if cerr != nil {
		panic(cerr)
	}
	fmt.Println("number of red cars:", n)
}
