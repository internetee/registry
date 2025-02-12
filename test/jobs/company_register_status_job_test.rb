require "test_helper"

Company = Struct.new(:registration_number, :company_name, :status)

class CompanyRegisterStatusJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper 

  REGISTERED = 'R'
  LIQUIDATED = 'L'
  BANKRUPT = 'N'
  DELETED = 'K'

  setup do
    @registrant_acme = contacts(:acme_ltd).becomes(Registrant)
    @registrant_jack = contacts(:jack).becomes(Registrant)
    @registrant_william = contacts(:william).becomes(Registrant)

    contact = contacts(:john)
    @registrant = contact.becomes(Registrant)
  end

  def test_if_company_wasn_not_checked_before_it_should_be_checked
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', REGISTERED), Company.new('14112620', 'Jack', REGISTERED)]
      end
      object
    end

    @registrant_acme.update!(company_register_status: nil, checked_company_at: nil, ident_type: 'org', ident_country_code: 'EE', ident: '16752073')
    @registrant_jack.update!(company_register_status: nil, checked_company_at: nil, ident_type: 'org', ident_country_code: 'EE', ident: '14112620')

    @registrant_acme.reload && @registrant_jack.reload

    assert_nil @registrant_acme.checked_company_at
    assert_nil @registrant_acme.company_register_status
    assert_nil @registrant_jack.checked_company_at
    assert_nil @registrant_jack.company_register_status

    CompanyRegisterStatusJob.perform_now(14, 0, 100)

    @registrant_acme.reload && @registrant_jack.reload

    assert_not_nil @registrant_jack.checked_company_at
    assert_not_nil @registrant_jack.company_register_status
    assert_not_nil @registrant_acme.checked_company_at
    assert_not_nil @registrant_acme.company_register_status


    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_what_was_checked_before_specific_days_should_be_not_checked
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', REGISTERED)]
      end
      object
    end

    interval_days = 14
    current_time = Time.zone.now

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: current_time - (interval_days.days - 2.days),
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(interval_days, 0, 100)

    @registrant_acme.reload

    assert_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_from_other_countries_are_skipped
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', REGISTERED)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: nil,
      checked_company_at: nil,
      ident_type: 'org',
      ident_country_code: 'US',
      ident: '16752073'
    )

    @registrant_acme.reload

    assert_nil @registrant_acme.checked_company_at
    assert_nil @registrant_acme.company_register_status

    CompanyRegisterStatusJob.perform_now(14, 0, 100)

    @registrant_acme.reload

    assert_nil @registrant_acme.checked_company_at
    assert_nil @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_what_was_checked_before_specific_days_should_be_checked
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', REGISTERED)]
      end
      object
    end

    interval_days = 14
    current_time = Time.zone.now

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: current_time - (interval_days.days + 1.day),
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(interval_days, 0, 100)

    @registrant_acme.reload

    assert_not_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date
    assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_with_invalid_ident_should_receive_invalid_ident_notification
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', DELETED)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::DELETED,
      checked_company_at: nil,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    CompanyRegisterStatusJob.perform_now(14, 0, 100)

    @registrant_acme.reload

    assert_equal Contact::DELETED, @registrant_acme.company_register_status

    template = I18n.t('invalid_ident',
                     ident: @registrant_acme.ident,
                     domain_name: @registrant_acme.registrant_domains.first.name,
                     outzone_date: @registrant_acme.registrant_domains.first.outzone_date,
                     purge_date: @registrant_acme.registrant_domains.first.purge_date,
                     notes: "Contact has status deleted")
    assert_equal @registrant_acme.registrant_domains.first.registrar.notifications.last.text, template

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_with_force_delete_and_status_R_should_be_lifted
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', REGISTERED)]
      end
      object
    end

    interval_days = 14
    current_time = Time.zone.now

    @registrant_acme.update!(
      company_register_status: nil,
      checked_company_at: current_time - (interval_days.days + 1.day),
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    @registrant_acme.registrant_domains.each do |domain|
      domain.schedule_force_delete(
        type: :fast_track,
        notify_by_email: true,
        reason: 'invalid_company',
        email: @registrant_acme.email
      )
    end

    assert @registrant_acme.registrant_domains.all?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(interval_days, 0, 100)

    @registrant_acme.reload

    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)
    assert_equal Contact::REGISTERED, @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_with_status_L_should_be_inform_by_email
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', LIQUIDATED)]
      end
      object
    end

    interval_days = 14
    current_time = Time.zone.now

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: current_time - (interval_days.days + 1.day),
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    ActionMailer::Base.deliveries.clear
    assert_emails 0

    CompanyRegisterStatusJob.perform_now(interval_days, 0, 100)

    @registrant_acme.reload

    assert_emails 1
    assert_equal Contact::LIQUIDATED, @registrant_acme.company_register_status
    
    email = ActionMailer::Base.deliveries.last
    assert_equal [@registrant_acme.email], email.to
    assert_equal 'Kas soovite oma .ee domeeni säilitada? / Do you wish to preserve your .ee registration?', email.subject

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_with_status_N_should_be_scheduled_for_force_delete
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', BANKRUPT)]
      end
      object
    end

    interval_days = 14
    current_time = Time.zone.now

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: current_time - (interval_days.days + 1.day),
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    
    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(interval_days, 0, 100)

    @registrant_acme.reload

    assert_not @registrant_acme.registrant_domains.all?(&:force_delete_scheduled?)
    assert_equal Contact::BANKRUPT, @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_with_status_K_should_be_scheduled_for_force_delete
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', DELETED)]
      end
      object
    end

    interval_days = 14
    current_time = Time.zone.now

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: current_time - (interval_days.days + 1.day),
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    
    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(interval_days, 0, 100)

    @registrant_acme.reload

    assert @registrant_acme.registrant_domains.all?(&:force_delete_scheduled?)
    assert_equal Contact::DELETED, @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_company_information_what_was_not_found_in_register_should_be_deleted
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        []
      end
      object
    end

    interval_days = 14
    current_time = Time.zone.now

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: current_time - (interval_days.days + 1.day),
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    
    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(interval_days, 0, 100)

    @registrant_acme.reload

    assert @registrant_acme.registrant_domains.all?(&:force_delete_scheduled?)
    assert_equal Contact::DELETED, @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end
end
