require 'sequel'

#
# Database configuration
#
# You can do whatever you want here, as long as you end up with a 'DB' instance
#
# Some advices though :
#
# - you can select different DB according to your running mode
# (spec, dev, live, see environment.rb)
#
# - you can use R/W splitting, sharding, etc...
# (see http://sequel.rubyforge.org/rdoc/files/doc/sharding_rdoc.html)
#

case Ramaze.options.mode
when :spec
  DB = Sequel.mysql2(
    'powerdns', 
    :user=>'root', 
    :password=>'')
  DATABASE = 'powerdns'
when :dev
  DB = Sequel.mysql2(
    'powerdns-dev', 
    :user=>'root', 
    :password=>'')
  DATABASE = 'powerdns-dev'
else
  puts "No database configured for #{Ramaze.options.mode}"
  exit
end

