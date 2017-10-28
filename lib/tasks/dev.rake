namespace :dev do
  desc 'Generates dummy data in development environment' \
             ' (options: [random] for random data generation - slowest)'

  task :prime, [:random] => :environment do |t, args|
    abort 'Production environment is not supported' if Rails.env.production?

    include FactoryBot::Syntax::Methods

    PaperTrail.enabled = false
    Domain.paper_trail_on!
    Contact.paper_trail_on!

    with_random_data = args[:random].present?

    def create_domain(name:, registrar:, registrant:, account:, price:, reg_time:)
      duration = price.duration.sub('mons', 'months').split("\s")
      period = duration.first.to_i
      period_unit = duration.second[0]

      create(:domain,
             name: name,
             period: period,
             period_unit: period_unit,
             registered_at: reg_time,
             valid_from: reg_time,
             expire_time: reg_time + period.send(duration.second.to_sym),
             created_at: reg_time,
             updated_at: reg_time,
             registrar: registrar,
             registrant: registrant)

      create(:account_activity,
             account: account,
             sum: -price.price.amount,
             activity_type: AccountActivity::CREATE,
             created_at: reg_time,
             updated_at: reg_time,
             price: price)
    end

    def generate_default_data
      create(:admin_user, username: 'test', password: 'testtest', password_confirmation: 'testtest')

      zone = create(:zone, origin: 'test')
      registrar = create(:registrar, name: 'test')
      registrant = create(:registrant, name: 'test', registrar: registrar)

      account = create(:account, registrar: registrar, balance: 1_000_000)
      api_user = create(:api_user, username: 'test', password: 'testtest', registrar: registrar)

      epp_session = build(:epp_session, registrar: registrar)
      epp_session[:api_user_id] = api_user.id
      epp_session.registrar_id = registrar.id
      epp_session.save!

      domain_counter = 1.step

      Billing::Price.durations.each do |duration|
        Billing::Price.operation_categories.each do |operation_category|
          price = create(:price,
                         price: Money.from_amount(duration.to_i * 10),
                         valid_from: Time.zone.now - rand(1).months,
                         valid_to: Time.zone.now + rand(1).months,
                         duration: duration,
                         operation_category: operation_category,
                         zone: zone)

          next if operation_category == 'renew'

          (rand(3) + 1).times do
            create_domain(name: "test#{domain_counter.next}.test",
                          registrar: registrar,
                          registrant: registrant,
                          account: account,
                          price: price,
                          reg_time: 1.month.ago)
          end

          (rand(3) + 1).times do
            create_domain(name: "test#{domain_counter.next}.test",
                          registrar: registrar,
                          registrant: registrant,
                          account: account,
                          price: price,
                          reg_time: Time.zone.now)
          end
        end
      end

      create_domain(name: 'test.test',
                    registrar: registrar,
                    registrant: registrant,
                    account: account,
                    price: Billing::Price.first,
                    reg_time: Time.zone.now)
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

    Setting.registrar_ip_whitelist_enabled = false

    ActiveRecord::Base.transaction do
      generate_default_data
      generate_random_data if with_random_data
    end
  end
end
