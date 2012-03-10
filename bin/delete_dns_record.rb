#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require File.join(File.dirname(__FILE__),'..','lib','dns_tools')
require 'trollop'

script_name = __FILE__.split('/').last
opts = Trollop::options do
  version "#{script_name} © 2012 Erwan Arzur <earzur@gmail.com>" 
  banner <<-EOS
Update a pdns database (mysql) by removing records. #{script_name} removes a record named after --record-name from
the zone for domain (--domain). A record in the domains table must exist for this domain.

#{script_name} --database-config config.yaml --domain example.com --record-name host01
removes test01.example.com 

Usage:
    #{script_name} [options]
where [options] are:
EOS
  opt :database_config, 'database configuration file in YAML format, comforming to rails'' database.yml syntax', :type => :string
  opt :domain, 'domain name to update', :type => :string
  opt :record_name, 'IP address of the host to remove. The script will look for this value in records.content', :type => :string
  opt :delete_cnames, "remove the cnames pointing to the record to remove"
  opt :verbose, "be verbose about what's going on"
end

Trollop::die :database_config, 'is mandatory' unless opts[:database_config]
Trollop::die :domain, 'is mandatory' unless opts[:domain]
Trollop::die :record_name, 'is mandatory' unless opts[:record_name]

Trollop::die :domain, "#{opts[:domain]} is not a valid domain name" unless DNSTools::Tools.is_fqdn?(opts[:domain])
Trollop::die :database_config, "#{opts[:database_config]}: no such file or directory" unless File.exist?(opts[:database_config])

DNSTools::DNSUpdater.set_debug true if opts[:verbose]
DNSTools::DNSUpdater.set_force_cname_update true if opts[:force_cname_update]


#### option parsing done, let's work ...

record_name = opts[:record_name]
domain      = opts[:domain]

#record_name = DNSTools::Tools.build_fqdn(record_name,domain) unless DNSTools::Tools.is_fqdn?(record_name)
begin
  database_config = DNSTools::Tools.load_database_config(opts[:database_config])
rescue IOError => e
  STDERR.puts "Cannot load configuration file: #{opts[:database_config]}: #{e.to_s}"
  STDERR.puts e.backtrace.join("\n")
  exit 255
end

connection = DNSTools::Tools.connect(database_config)
dns_updater = DNSTools::DNSUpdater.new(connection,opts[:domain])
dns_updater.delete_host(record_name,opts[:delete_cnames])
DNSTools::Tools.close(connection)
exit 0