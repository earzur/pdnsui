# This file is used for loading all your models. Note that you don't have to actually use
# this file. The great thing about Ramaze is that you're free to change it the way you see
# fit.

require 'sequel'

# Database setup
# Setup takes place in an external .gitignore'd file
# so credentials are not in the repos

require __DIR__('db_connect')

# Models

require __DIR__('domain')
require __DIR__('record')
