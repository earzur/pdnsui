#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require File.join(File.dirname(__FILE__),'..','lib','dns_tools')
require 'trollop'

script_name = __FILE__.split('/').last
opts = Trollop::options do
  version "#{script_name} © 2012 Erwan Arzur <earzur@gmail.com>" 
  banner <<-EOS
Update a pdns database (mysql) with new records. 

#{script_name} adds a record named after the name template (--template)
into the zone for domain (--domain). The zone must already exist (in the 'domains' table), or
the command will fail

#{script_name} --database-config config.yaml --domain example.com --template host --address 10.0.0.1 --cnames test
will add host001.example.com with ip address 10.0.0.1 and test.example.com pointing to this new record

Usage:
    #{script_name} [options]
where [options] are:
EOS
  opt :database_config, 'database configuration file in YAML format, comforming to rails'' database.yml syntax', :type => :string
  opt :domain, 'domain name to update', :type => :string
  opt :template, 'the name template for the A record defaults to "auto_host"', :type => :string
  opt :address, "IP address to associate with the new A record", :type => :string
  opt :count, "Force the counter of host created, regardless of the number of hosts with the same template", :type => :integer
  opt :cnames, "comma separated list of CNAME record to create (update if --force-cname-update is specified) and link to the new record", :type => :string
  opt :force_cname_update, "force update when existing CNAME records are found"
  opt :verbose, "be verbose about what's going on"
end

Trollop::die :database_config, 'is mandatory' unless opts[:database_config]
Trollop::die :domain, 'is mandatory' unless opts[:domain]
opts[:template] = 'auto_host' unless opts[:template]
Trollop::die :address, 'is mandatory' unless opts[:address]
opts[:cnames] = "" unless opts[:cnames]

Trollop::die :domain, "#{opts[:domain]} is not a valid domain name" unless DNSTools::Tools.is_fqdn?(opts[:domain])
Trollop::die :address, "#{opts[:address]} is not a valid IPV4 address" unless DNSTools::Tools.is_ip?(opts[:address])
Trollop::die :template, "#{opts[:template]} must not contain dots" if DNSTools::Tools.is_fqdn?(opts[:template])
Trollop::die :database_config, "#{opts[:database_config]}: no such file or directory" unless File.exist?(opts[:database_config])

#puts "#{opts[:address]} #{is_ip?(opts[:address]).inspect}"

DNSTools::DNSUpdater.set_debug true if opts[:verbose]
DNSTools::DNSUpdater.set_force_cname_update true if opts[:force_cname_update]

cnames = opts[:cnames].gsub(/ /,'').split(',')

#### option parsing done, let's work ...

begin
  database_config = DNSTools::Tools.load_database_config(opts[:database_config])
rescue IOError => e
  STDERR.puts "Cannot load configuration file: #{opts[:database_config]}: #{e.to_s}"
  STDERR.puts e.backtrace.join("\nA")
end
connection = DNSTools::Tools.connect(database_config)
dns_updater = DNSTools::DNSUpdater.new(connection,opts[:domain])

record_name = dns_updater.add_host(opts[:template],opts[:address],cnames,180,opts[:count])
puts "ADDED #{record_name}"
DNSTools::Tools.close(connection)