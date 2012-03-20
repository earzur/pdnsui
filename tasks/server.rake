namespace :server do
  desc 'Starts server'
  task :start => [ :yard ] do
    sh("ramaze start -s thin")
  end
end
