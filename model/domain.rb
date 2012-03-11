class Domain < Sequel::Model
  one_to_many :records
end
