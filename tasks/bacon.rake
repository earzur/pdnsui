desc "Runs bacon tests with code coverage"
task :bacon do
  require 'simplecov'

  ENV['MODE'] = 'spec'

  SimpleCov.start do
    add_group "Models", "model/"
    add_group "Controllers", "controller/"
    add_filter "spec/"
  end

  # Load the existing files
  Dir.glob('spec/*.rb').each do |spec_file|
    unless File.basename(spec_file) == 'init.rb' and File.basename(spec_file) == 'helper.rb'
      puts "Doing #{spec_file}"
      require File.expand_path(spec_file)
    end
  end

end
