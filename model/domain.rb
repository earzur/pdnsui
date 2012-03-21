class Domain < Sequel::Model
  one_to_many :records, :before_remove => :remove_records

  def before_destroy
    Record.filter(:domain_id => id).destroy
  end

  def soa(value)
    soaline = Record.filter(:domain_id => id, :type => 'SOA')

    indexes = [ :ns, :contact, :serial, :refresh, :retry, :expiry, :minimum ]

    if !indexes.index(value).nil?
      soaline.first.content.split[indexes.index(value)]
    end

    nil
  end

  def serial
    soaline = Record.filter(:domain_id => id, :type => 'SOA')

  end
end
