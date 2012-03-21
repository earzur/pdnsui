desc "Runs bacon tests with code coverage"
task :bacon do
  require 'simplecov'
  require 'bacon'

  ENV['RACK_ENV'] = 'spec'

  Bacon.const_set :Backtraces, false unless ENV['BACON_MUTE'].nil? 

  SimpleCov.start do
    add_group "Models", "model/"
    add_group "Controllers", "controller/"
    add_filter "spec/"
  end

  require File.expand_path('spec/init.rb')

end
