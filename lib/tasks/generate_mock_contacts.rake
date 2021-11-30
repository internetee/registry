namespace :generate_mock do
  task contacts: :environment do
    3000.times do
      c = Contact.new
      c.name = generate_random_string
      c.email = generate_random_string + "@" + generate_random_string + ".ee"
      c.registrar_id = registrar
      c.street = generate_random_string
      c.city = generate_random_string
      c.zip = '12323'
      c.country_code = 'EE'
      c.phone = "+372.59813318"
      c.ident_country_code = 'EE'
      c.ident_type = 'priv'
      c.ident = '38903110313'
      c.code = generate_random_string + ":" + generate_random_string
      c.save
    end
  end

  def generate_random_string
    (0...10).map { (65 + rand(26)).chr }.join
  end

    def registrar
      Registrar.last.id
    end
end
#
namespace :generate_mock do

  task domains: :environment do
    registrant = Registrant.last
    registrar = Registrar.last
    contact = Contact.find_by(code: 'BFOYJWMWNW:PWUKDUTVGQ')

    1000.times do
      d = Domain.new
      d.valid_to = Time.zone.now + 1.year
      d.name = generate_random_string + ".ee"
      d.registrar_id = registrar.id
      d.registrant = registrant
      d.period = 1
      d.admin_contacts << contact
      d.tech_contacts << contact
      d.save

      p "++++++"
      p d
      p "+++++"
    end
  end

  def generate_random_string
    (0...10).map { (65 + rand(26)).chr }.join
  end

    def registrar
      Registrar.last.id
    end
end
