desc 'Generate YARD documentation'
task :yard do
  readme = File.expand_path('../../README.md', __FILE__)
  sh("yardoc controller/**/*.rb model/**/*.rb --exclude db-connect.rb -o public/doc -r #{readme}")
end
