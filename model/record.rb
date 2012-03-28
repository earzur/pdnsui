class Record < Sequel::Model
  many_to_one :domain
  plugin :validation_helpers

  # We can only have one SOA per domain
  # Also, we can not have exactly the same records
  def validate
    if type == 'SOA'
      validates_unique([:domain_id, :type]) 
    else
      validates_unique([:domain_id, :name, :type, :content])
    end
  end

  def serial
    content.split[2] if type == 'SOA'
  end

  def refresh
    content.split[3] if type == 'SOA'
  end

  def retry
    content.split[4] if type == 'SOA'
  end

  def expiry
    content.split[5] if type == 'SOA'
  end

  def minimum
    content.split[6] if type == 'SOA'
  end
end

