class Record < Sequel::Model
  many_to_one :domain
end

