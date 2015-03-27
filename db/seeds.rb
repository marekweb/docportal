# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if ENV['ADMIN_PASSWORD'].nil?
  throw 'Need to set ADMIN_PASSWORD for this task, to create admin user'
end

admin_user = User.create!(first_name: 'Real Ventures', last_name: 'Admin', email: 'admin@realventures.com', password: ENV['ADMIN_PASSWORD'])
