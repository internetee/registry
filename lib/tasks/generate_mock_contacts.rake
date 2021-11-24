# namespace :generate_mock do
#   task contacts: :environment do
#     1000.times do
#       c = Contact.new
#       c.name = generate_random_string
#       c.email = generate_random_string + "@" + generate_random_string + ".ee"
#       c.registrar_id = registrar
#       c.street = generate_random_string
#       c.city = generate_random_string
#       c.zip = '12323'
#       c.country_code = 'EE'
#       c.phone = "+372.59813318"
#       c.ident_country_code = 'EE'
#       c.ident_type = 'priv'
#       c.ident = '38903110313'
#       c.code = generate_random_string + ":" + generate_random_string
#       c.save
#     end
#   end
#
#   def generate_random_string
#     (0...10).map { (65 + rand(26)).chr }.join
#   end
#
#     def registrar
#       Registrar.last.id
#     end
# end
