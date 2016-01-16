require 'faker'
require 'database_cleaner'

# Truncate tables
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# Users
user = User.create({
  email: 'me@hugw.io',
  name: 'Hugo W.',
  password: 'admin123',
  password_confirmation: 'admin123',
  status: 'active'
})
