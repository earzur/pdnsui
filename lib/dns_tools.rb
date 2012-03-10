require 'yaml'
require 'mysql'

module DNSTools
  class Tools
      
    def self.is_ip?(ip)
      splitted = ip.split('.')
      return false unless splitted.size==4
      splitted.each do |byte|
        return false unless (byte.to_i >= 0 and byte.to_i <= 255)
      end
      return true
    end

    def self.clean_leading_and_trailing_dots(name)
      name = name.sub(/^\./,'')
      name = name.sub(/\.$/,'')
      name
    end

    def self.build_fqdn(hostname, domain)
      "#{Tools.clean_leading_and_trailing_dots hostname}.#{Tools.clean_leading_and_trailing_dots domain}"
    end

    def self.is_fqdn?(hostname)
      # hostname.match(/^\w+\.(\w+\.)*\w+$/)
      hostname.split('.').size > 1
    end

    def self.load_database_config(path)
      conf = YAML.load_file(path)['production']
      if conf['adapter'] != 'mysql'
        raise ArgumentError, "database adapter #{conf['adapter']} is not supported (only mysql)"
      end
      conf
    end

    def self.with_lock (dbh, table_name, &block)
      dbh.query("lock tables #{table_name} read")
      yield block
    rescue Mysql::Error => e
      STDERR.puts "Excepion occured in lock blok: #{e.to_s}"
      raise e
    ensure
      begin
        dbh.query("unlock tables")
      rescue => e
        STDERR.puts "Error unlocking #{table_name}: #{e.to_s}"
      end
    end
    
    def self.connect(database_config)
      dbh = Mysql.real_connect(database_config['host'],database_config['username'],
                               database_config['password'],database_config['database'])
      dbh
    rescue => e
      STDERR.puts "Cannot connect to #{database_config['username']}@#{database_config['host']}:#{database_config['database']} #{e.to_s}"
      dbh.close rescue nil if dbh
      raise e
    end

    def self.close(dbh)
      dbh.close if dbh
    rescue  => e
      STDERR.puts "Cannot close connection to #{@pdns_database_user}@#{@pdns_database_server}:#{@pds_database} #{e.to_s}"
      raise e
    end  
  end
  
  class DNSUpdater
    
    @@debug = false
    @@force_cname_update = false
    
    attr_reader :force_cname_update,:debug
      
    attr_accessor :domain_name,:domain_id

    attr_reader :connection
    
    def self.set_debug(new_debug)
      puts "debug set: #{new_debug}"
      @@debug = new_debug
    end
      
    def self.set_force_cname_update(force)
      @@force_cname_update = force
    end
      
    def self.setup_dns_updater(domain_name)
      raise ArgumentError.new("Please set DATABASE_CONFIG to point to a PowerDNS database !") unless ENV['DATABASE_CONFIG']
      db_config = ENV['DATABASE_CONFIG']
      begin
        database_config = Tools.load_database_config(db_config)
      rescue IOError => e
        STDERR.puts "Cannot load configuration file: #{db_config}: #{e.to_s}"
        STDERR.puts e.backtrace.join("\n")
      end
      connection = Tools.connect(database_config)
      new(connection,domain_name)
    end

    def initialize(connection, domain_name)
      @domain_name = domain_name
      @connection = connection
      @domain_id = get_domain_id
      puts "#{domain_name}: id #{domain_id}" if @@debug
    end

    def add_host(name_template, ip_address, cnames,ttl = 180,count = nil)  
      name_template = Tools.clean_leading_and_trailing_dots(name_template)
      connection.autocommit(false)
        
      if count
        host_count = count
      else
        host_count = get_host_count(name_template) + 1 ## count the number of existing hosts only when count is nil
      end
        
      puts "number of hosts starting with #{name_template}: #{host_count}" if @@debug
      record_name = Tools.build_fqdn("#{name_template}-%03d" % (host_count), domain_name)
      puts "Inserting new record: #{record_name}" if @@debug
      insert_record(record_name,'A',ip_address,ttl)
      if cnames && !cnames.empty?
        insert_or_update_cname_records(cnames.collect { |cname| Tools.build_fqdn cname,domain_name },record_name,ttl)
      end
      update_soa_record
      connection.commit
      return record_name
    rescue => e
      STDERR.puts "Error: #{e.to_s}"
      STDERR.puts e.backtrace.join("\n")
      connection.rollback
    end

    def delete_host(ip_address,delete_cnames)
      connection.autocommit(false)
      puts "Looking for A record for #{ip_address}" if @@debug
      data = get_record_by_content(ip_address,'A')
      if data
        puts "Found #{data.size} record(s)" if @@debug
        host_name = data.first['name']
        if delete_cnames
          puts "Deleting CNAME records pointing to #{host_name}:#{data['content']}" if @@debug
          delete_record_by_content_and_type(host_name,'CNAME')
        end
        puts "Deleting A record for #{host_name}" if @@debug
        delete_record_by_name_and_type(host_name,'A')
      end
      update_soa_record
      puts "Commiting transaction ..." if @@debug
      connection.commit
    rescue Mysql::Error => e
      STDERR.puts "Cannot delete record for #{host_name} (rollbacked): #{e.to_s}"
      STDERR.puts e.backtrace.join("\n")
      connection.rollback 
    ensure
      connection.autocommit(false)
    end
    def get_record_by_name(record_name,type)
      query = "select * from records where domain_id=#{domain_id} and name='#{record_name}' and type='#{type}'"
      puts "query: #{query}" if @@debug
      res = nil
      Tools.with_lock(connection,'records') do
        res = connection.query query
      end
      if res.num_rows > 0
        result = []
        res.each_hash do |row|
          result << row
        end
        puts "found #{result.size} matching rows ..." if @@debug
        return result
      end
      return nil
    rescue Mysql::Error => e
      STDERR.puts "Cannot run query: #{query}: #{e.to_s}"
      raise e
    end

    def get_record_by_content(content,type)
      query = "select * from records where domain_id=#{domain_id} and content='#{content}' and type='#{type}'"
      puts "query: #{query}" if @@debug
      res = nil
      Tools.with_lock(connection,'records') do
        res = connection.query query
      end
      if res.num_rows > 0
        result = []
        res.each_hash do |row|
          result << row
        end
        puts "found #{result.size} matching rows ..." if @@debug
        return result
      end
      return nil
    rescue Mysql::Error => e
      STDERR.puts "Cannot run query: #{query}: #{e.to_s}"
      raise e
    end
      

    private
    
    def get_domain_id
      query = "select id from domains where name='#{domain_name}'"
      if @@debug
        puts("query: #{query}")
      end
      res = connection.query(query)
      puts "Found #{res.num_rows} domains records for #{domain_name}" if @@debug
      if res.num_rows == 1 
        res.fetch_hash['id'].to_i
      else 
        raise ArgumentError, "Cannot find exact match for #{domain_name} : #{res.num_rows} result(s)"
      end
    rescue Mysql::Error => e
      begin
        STDERR.puts "Cannot get domain information for #{domain_name}: #{e.to_s}"
        raise e
      ensure
        res.free if res
      end
    end
    
    def get_host_count(name_template)
      query = "select max(name) from records where domain_id=#{domain_id} and name like '#{name_template}%'"
      puts "query: #{query}" if @@debug
      res = nil
      Tools.with_lock(connection,'records') do
        res = connection.query(query)
      end
      if res
        hash = res.fetch_hash 
        if hash 
          puts "result: #{hash.inspect}" if @@debug
          max = hash['max(name)'] ## lexicographical maximum
            
          return max.match(/\d+/)[0].to_i rescue 0 ## extract the host counter
        end
      end
    rescue Mysql::Error => e
      STDERR.puts "Cannot get count of host matching #{name_template}%.#{domain_id}: #{e.to_s}"
      raise e
    end

    def get_highest_host_number(name_template)
      query = "select name from records where domain_id=#{domain_id} and name like '#{name_template}%' order by name desc limit 0,1"
      puts "query: #{query}" if @@debug
      res = nil
      Tools.with_lock(connection,'records') do
        res = connection.query(query)
      end
      if res
        hash = res.fetch_hash 
        if hash 
          puts "result: #{hash.inspect}" if @@debug
          return hash['name'].match(/(\d{3,3})\./)[1].to_i # Regexp: get 3 numbers before a "."
        end
      end
    rescue Mysql::Error => e
      STDERR.puts "Cannot get highest host number matching #{name_template}%.#{domain_id}: #{e.to_s}"
      raise e
    end

    def insert_record(record_name,type,content,ttl = 180)
      query = "insert into records (domain_id,name,type,content,ttl,change_date) values"\
              " (%d,'%s','%s','%s',%d,%d)" % [domain_id,record_name,type,content,ttl,Time.now.to_i]
      puts "query: #{query}" if @@debug
      connection.query(query)
      puts "row created ..." if @@debug
    rescue Mysql::Error => e
      STDERR.puts "Cannot run query: #{query}: #{e.to_s}"
      raise e
    end
      
    def delete_record_by_name_and_type(record_name,type)
      query = "delete from records where name='#{record_name}' and domain_id=#{domain_id} and type='#{type}'"
      puts "query: #{query}" if @@debug
      connection.query(query)
    rescue Mysql::Error => e
      STDERR.puts "Cannot delete record for #{record_name}('#{record_type}') #{e.to_s}"
      raise e
    end

    def delete_record_by_content_and_type(content,type)
      query = "delete from records where content='#{content}' and domain_id=#{domain_id} and type='#{type}'"
      puts "query: #{query}" if @@debug
      connection.query(query)
    rescue Mysql::Error => e
      STDERR.puts "Cannot delete record for #{content}('#{record_type}') #{e.to_s}"
      raise e
    end
      
    def insert_or_update_cname_records(cnames,record_name,ttl = 180) 

#        connection.autocommit false
      query = nil
      cnames.each do |cname|
        exist = nil
        Tools.with_lock(connection,'records') do
          exist = get_record_by_name(cname,'CNAME')
        end
        if (exist.nil?) 
          insert_record(cname,'CNAME',record_name)
        elsif force_cname_update
          puts "Found existing record(s): #{exist.inspect}. Updating the first row" if @@debug
          query = "update records set content='#{record_name}',ttl=#{ttl}, change_date=#{Time.now.to_i} where id=#{exist[0]['id']}"
          puts "query: #{query}" if @@debug
          connection.query query
        else
          puts "Found existing record(s): #{exist.inspect}. Updating" if @@debug
          #STDERR.puts "not updating existing CNAME record for #{cname}"
        end
      end
#        connection.commit
    rescue Mysql::Error => e
      STDERR.puts "Cannot run query: #{query} (rollbacked): #{e.to_s}"
#        connection.rollback 
      raise e
    # ensure
    #   connection.autocommit true
    end

    def update_soa_record
      recs = get_record_by_name(domain_name,"SOA")
      if (recs.length == 1)
        content = recs[0]['content'];
        primary_ns, contact, serial, refresh, soa_retry, expire, minimum =
          content.split(/\s+/) unless content.empty?
        serial = serial.to_i

        date_serial = Time.now.strftime( "%Y%m%d00" ).to_i
        serial = if serial.nil? || date_serial > serial
           date_serial
        else
           serial + 1
        end

        puts "serial: new serial #{serial}" if @@debug
        new_content = "#{primary_ns} #{contact} #{serial} #{refresh} #{soa_retry} #{expire} #{minimum}"
        query = "update records set content='#{new_content}' where id=#{recs[0]['id']}"
        puts "query: #{query}" if @@debug
        connection.query(query)
      end
    rescue Mysql::Error => e
      STDERR.puts "cannot update serial for #{domain_name}: #{e.to_s}"
      raise e
    end
  end
end
