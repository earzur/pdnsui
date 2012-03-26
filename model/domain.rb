class Domain < Sequel::Model
  one_to_many :records, :before_remove => :remove_records
  plugin :validation_helpers

  def validate
    super
    validates_presence [:name, :type]
    validates_unique :name
    #validates_includes ['A', 'CNAME', 'AAAA', 'PTR', 'NS', 'TXT' ], :type, :message=>'is not a valid type'
    validates_includes ['MASTER', 'SLAVE', 'NATIVE'], :type, :message => 'is not a valid domain type'
  end

  def before_destroy
    Record.filter(:domain_id => id).destroy
  end

  def soa
    Record.filter(:domain_id => id, :type => 'SOA').first
  end
end
