namespace :dev do
  desc 'Generates dummy data in development environment' \
             ' (options: [random] for random data generation - slowest)'

  task :prime, [:random] => :environment do |t, args|
    abort 'Production environment is not supported' if Rails.env.production?

    require 'factory_girl'
    include FactoryGirl::Syntax::Methods
    FactoryGirl.find_definitions

    PaperTrail.enabled = false
    with_random_data = args[:random].present?

    def generate_default_data
      create(:admin_user, username: 'test', password: 'testtest', password_confirmation: 'testtest')

      zone = create(:zone, origin: 'test')
      registrar = create(:registrar, name: 'test')
      registrant = create(:registrant, name: 'test', registrar: registrar)

      create(:account, registrar: registrar, balance: 1_000_000)
      create(:api_user, username: 'test', password: 'testtest', registrar: registrar)
      create(:domain,
             name: 'test.test',
             period: 1,
             period_unit: 'y',
             registered_at: Time.zone.now,
             valid_from: Time.zone.now,
             expire_time: Time.zone.now + 10.years,
             registrar: registrar,
             registrant: registrant)

      Billing::Price.durations.each do |duration|
        Billing::Price.operation_categories.each do |operation_category|
          create(:price,
                 price: Money.from_amount(1),
                 valid_from: Time.zone.now.beginning_of_day,
                 valid_to: Time.zone.now + 10.years,
                 duration: duration,
                 operation_category: operation_category,
                 zone: zone)
        end
      end
    end

    def generate_random_data
      zone_count = 10
      admin_user_count = 5
      registrar_count = 50
      api_user_count = 10
      registrant_count = 50
      domain_count = 50
      registrars = []
      registrants = []
      zones = []
      registrant_names = [
          'John Doe',
          'John Roe',
          'Jane Doe',
          'Jane Roe',
          'John Smith',
      ]

      zone_count.times do
        origin = SecureRandom.hex[0..(rand(5) + 1)]
        zones << create(:zone, origin: origin)
      end

      zone_origins = zones.collect { |zone| zone.origin }

      admin_user_count.times do
        uid = SecureRandom.hex[0..(rand(5) + 1)]
        create(:admin_user, username: "test#{uid}", password: 'testtest', password_confirmation: 'testtest')
      end

      registrar_count.times do
        uid = SecureRandom.hex[0..(rand(5) + 1)]
        registrars << create(:registrar, name: "Acme Ltd. #{uid}")
      end

      registrars.each do |registrar|
        create(:account, registrar: registrar, balance: rand(99999))

        api_user_count.times do |i|
          create(:api_user, username: "test#{registrar.id}#{i}", password: 'testtest', registrar: registrar)
        end

        registrant_count.times do |i|
          registrants << create(:registrant, name: registrant_names.sample, registrar: registrar)
        end

        domain_count.times do |i|
          name = "test#{registrar.id}#{i}#{rand(99999)}.#{zone_origins.sample}"
          period = rand(3) + 1

          create(:domain,
                 name: name,
                 period: period,
                 period_unit: 'y',
                 registered_at: Time.zone.now,
                 valid_from: Time.zone.now,
                 expire_time: Time.zone.now + period.years,
                 registrar: registrar,
                 registrant: registrants.sample)
        end
      end

      zones.each do |zone|
        Billing::Price.durations.each do |duration|
          Billing::Price.operation_categories.each do |operation_category|
            create(:price,
                   price: Money.from_amount(rand(10) + 1),
                   valid_from: Time.zone.now.beginning_of_day,
                   valid_to: Time.zone.now + (rand(10) + 1).years,
                   duration: duration,
                   operation_category: operation_category,
                   zone: zone)
          end
        end
      end
    end

    ActiveRecord::Base.transaction do
      generate_default_data
      generate_random_data if with_random_data
    end
  end
end
