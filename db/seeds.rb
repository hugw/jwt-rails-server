require 'faker'
require 'database_cleaner'

# Truncate tables
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# Users
active_user = User.create({
  email: 'me@hugw.io',
  name: 'Hugo W.',
  password: 'admin123',
  password_confirmation: 'admin123',
  status: 'active'
})

inactive_user = User.create({
  email: 'inactive@hugw.io',
  name: 'Hugo W.',
  password: 'admin123',
  password_confirmation: 'admin123',
  status: 'inactive'
})
