# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Country.where(name: 'Estonia', iso: 'EE').first_or_create
EppUser.where(username: 'gitlab', password: 'ghyt9e4fu', active: true).first_or_create
