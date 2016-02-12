# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

email = 'admin@example.com'
pw = SecureRandom.hex

admin_user = User.create!({first_name: "Portal", last_name: "Admin", email: email, password: pw})

box_access = BoxAccess.create!

puts "-" * 20
puts "CREATED ADMIN WITH TEMPORARY ACCESS #{email}:#{pw}"
puts "-" * 20
