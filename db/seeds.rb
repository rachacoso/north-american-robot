# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Trend.create([
	{ name: 'Paraben-Free Sun Care' }, 
	{ name: '5-Free Nail Care' },
	{ name: 'Natural Color Cosmetics' },
	{ name: 'Natural/Organic Hair Care' },
	{ name: 'Small Batch Beauty' },
	{ name: 'Tools & Devices' }
	])

KeyRetailer.create([
	{ name: 'Bergdorf Goodman' },
	{ name: 'Sephora' },
	{ name: 'SPACE NK' },
	{ name: 'ULTA' },
	{ name: 'Urban Outfitters' },
	{ name: "RICKY'S" }
	])