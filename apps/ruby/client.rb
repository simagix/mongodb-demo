#! /usr/bin/ruby
# Copyright 2018 Kuei-chun Chen. All rights reserved.

require 'mongo'

# client.rb 'mongodb://user:password@localhost:27017/test?authSource=admin'
# client = Mongo::Client.new('#{ARGV[0]}')

client_options = {
  database: 'keyhole',
  auth_source: 'admin',
  user: 'user',
  password: 'password',
  ssl: true,
  ssl_ca_cert: '/etc/ssl/certs/ca.pem',
  ssl_cert: '/etc/ssl/certs/client.pem',
  ssl_key: '/etc/ssl/certs/client.pem'
}

Mongo::Logger.logger.level = Logger::INFO
client = Mongo::Client.new(['localhost:27017'], client_options)
collection = client[:cars]

cnt = collection.find( { color: 'Red' } ).count
puts "number of red cars: #{cnt}"
