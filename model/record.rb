class Record < Sequel::Model
  many_to_one :domains
end

