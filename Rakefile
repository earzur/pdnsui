require 'rake'
require 'rake/clean'
require 'date'
require 'time'

# All the bacon specifications
PROJECT_SPECS = Dir.glob(File.expand_path('../spec/**/*.rb', __FILE__))
PROJECT_SPECS.reject! { |e| e =~ /init\.rb/ }

CLEAN.include %w[
  **/.*.sw?
  *.gem
  .config
  **/*~
  **/{data.db,cache.yaml}
  *.yaml
  pkg
  rdoc
  public/doc
  *coverage*
]

Dir.glob(File.expand_path('../tasks/*.rake', __FILE__)).each do |f|
  import(f)
end

namespace :server do
  # Handy shorthand to start server with thin
  # May be typing rake server:thin is just as long as typing 
  # ramaze start -s thin
  # ...
  desc "Starts server (development)"
  task :thin => [ :yard, "db:configure" ] do
    sh("ramaze start -s thin")
  end
end

require 'erb'

namespace :db do
  desc "Configures database"
  task :configure do
    # If there is not configuration file
    # just make one using erb
    unless File.exists?('model/db_connect.rb')
      File.open('model/db_connect.rb', 'w') do |new_file|
        new_file.write ERB.new(File.read('model/db_connect.erb')).result(binding)
      end
    end
  end
end

# Set the default task to running all the bacon specifications
task :default => [:bacon]

