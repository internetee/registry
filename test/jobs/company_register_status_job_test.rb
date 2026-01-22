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

  def test_sampling_includes_contacts_never_checked_before
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
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    assert_nil @registrant_acme.checked_company_at
    assert_nil @registrant_acme.company_register_status

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_not_nil @registrant_acme.checked_company_at
    assert_equal Contact::REGISTERED, @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_includes_registered_contacts_checked_over_year_ago
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', REGISTERED)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: 1.year.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_not_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date
    assert_equal Time.zone.now.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_excludes_registered_contacts_checked_within_year
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', REGISTERED)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: Time.zone.now - 1.year + 2.days,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_includes_liquidated_contacts_checked_over_month_ago
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', LIQUIDATED)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::LIQUIDATED,
      checked_company_at: 1.month.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_not_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date
    assert_equal Time.zone.now.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_excludes_liquidated_contacts_checked_within_month
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', LIQUIDATED)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::LIQUIDATED,
      checked_company_at: Time.zone.now - 1.month + 2.days,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_includes_bankrupt_contacts_checked_over_month_ago
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', BANKRUPT)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::BANKRUPT,
      checked_company_at: 1.month.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_not_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date
    assert_equal Time.zone.now.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_excludes_bankrupt_contacts_checked_within_month
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', BANKRUPT)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::BANKRUPT,
      checked_company_at: Time.zone.now - 1.month + 2.days,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_includes_deleted_contacts_checked_over_day_ago
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
      checked_company_at: 1.day.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_not_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_excludes_deleted_contacts_checked_today
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
      checked_company_at: Time.zone.now,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_excludes_not_found_contacts_permanently
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [] # Still not found
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::NOT_FOUND,
      checked_company_at: Time.zone.now - 1.year, # Even if checked a year ago
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_checked_at = @registrant_acme.checked_company_at

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    # Contact with NOT_FOUND status should never be rechecked
    assert_equal old_checked_at.to_date, @registrant_acme.checked_company_at.to_date

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_sampling_excludes_companies_from_other_countries
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

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_nil @registrant_acme.checked_company_at
    assert_nil @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  # =============================================================================
  # STATUS HANDLING TESTS - Testing actions based on company status
  # =============================================================================

  def test_company_not_found_in_registry_gets_force_delete_and_not_found_status
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [] # Company not found
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: nil,
      checked_company_at: nil,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    # Status should be set to NOT_FOUND
    assert_equal Contact::NOT_FOUND, @registrant_acme.company_register_status
    assert_not_nil @registrant_acme.checked_company_at

    # Force delete should be scheduled for all domains
    assert @registrant_acme.registrant_domains.all?(&:force_delete_scheduled?)

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_registered_company_with_force_delete_gets_lifted
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

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)
    assert_equal Contact::REGISTERED, @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_liquidated_company_receives_email_notification
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', LIQUIDATED)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: 1.year.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    ActionMailer::Base.deliveries.clear
    assert_emails 0

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_emails 1
    assert_equal Contact::LIQUIDATED, @registrant_acme.company_register_status

    email = ActionMailer::Base.deliveries.last
    assert_equal [@registrant_acme.email], email.to
    assert_equal 'Kas soovite oma .ee domeeni säilitada? / Do you wish to preserve your .ee registration?', email.subject

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_bankrupt_company_status_is_updated_but_no_force_delete
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', BANKRUPT)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: 1.year.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_not @registrant_acme.registrant_domains.all?(&:force_delete_scheduled?)
    assert_equal Contact::BANKRUPT, @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_deleted_company_gets_force_delete
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', DELETED)]
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: 1.year.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert @registrant_acme.registrant_domains.all?(&:force_delete_scheduled?)
    assert_equal Contact::DELETED, @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_deleted_company_receives_registrar_notification
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

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    assert_equal Contact::DELETED, @registrant_acme.company_register_status

    template = I18n.t('invalid_ident',
                     ident: @registrant_acme.ident,
                     domain_name: @registrant_acme.registrant_domains.first.name,
                     outzone_date: @registrant_acme.registrant_domains.first.outzone_date,
                     purge_date: @registrant_acme.registrant_domains.first.purge_date,
                     force_delete_type: 'Fast Track',
                     force_delete_start_date: @registrant_acme.registrant_domains.first.force_delete_start.strftime('%d.%m.%Y'),
                     notes: "Contact has status deleted")
    assert_equal @registrant_acme.registrant_domains.first.registrar.notifications.last.text, template

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  # =============================================================================
  # SOAP FAULT ERROR HANDLING TESTS
  # =============================================================================

  def test_soap_fault_error_on_simple_data_skips_contact_without_changes
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        raise CompanyRegister::SOAPFaultError, "Päringute limiit on täis"
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: 1.year.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload
    old_status = @registrant_acme.company_register_status
    old_checked_at = @registrant_acme.checked_company_at

    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    # Status should remain unchanged
    assert_equal old_status, @registrant_acme.company_register_status
    # checked_company_at should remain unchanged
    assert_equal old_checked_at.to_i, @registrant_acme.checked_company_at.to_i
    # No force delete should be scheduled
    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_soap_fault_error_on_company_details_skips_force_delete
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        [Company.new('16752073', 'ACME Ltd', DELETED)]
      end
      def object.company_details(registration_number:)
        raise CompanyRegister::SOAPFaultError, "Päringute limiit on täis"
      end
      object
    end

    @registrant_acme.update!(
      company_register_status: Contact::REGISTERED,
      checked_company_at: 1.year.ago,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    @registrant_acme.reload

    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload

    # Status should be updated (simple_data worked)
    assert_equal Contact::DELETED, @registrant_acme.company_register_status
    # But no force delete should be scheduled (company_details failed)
    assert_not @registrant_acme.registrant_domains.any?(&:force_delete_scheduled?)

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_soap_fault_error_continues_processing_other_contacts
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.simple_data(registration_number:)
        if registration_number == '16752073'
          raise CompanyRegister::SOAPFaultError, "Päringute limiit on täis"
        else
          [Company.new(registration_number, 'Other Company', REGISTERED)]
        end
      end
      object
    end

    # First contact will fail
    @registrant_acme.update!(
      company_register_status: nil,
      checked_company_at: nil,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '16752073'
    )

    # Second contact will succeed
    @registrant_jack.update!(
      company_register_status: nil,
      checked_company_at: nil,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '14112620'
    )

    @registrant_acme.reload
    @registrant_jack.reload

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload
    @registrant_jack.reload

    # First contact should remain unchanged (SOAP fault)
    assert_nil @registrant_acme.company_register_status
    assert_nil @registrant_acme.checked_company_at

    # Second contact should be updated (success)
    assert_equal Contact::REGISTERED, @registrant_jack.company_register_status
    assert_not_nil @registrant_jack.checked_company_at

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  # =============================================================================
  # MULTIPLE CONTACTS TESTS
  # =============================================================================

  def test_multiple_unchecked_contacts_are_all_checked
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

    CompanyRegisterStatusJob.perform_now(0)

    @registrant_acme.reload && @registrant_jack.reload

    assert_not_nil @registrant_jack.checked_company_at
    assert_not_nil @registrant_jack.company_register_status
    assert_not_nil @registrant_acme.checked_company_at
    assert_not_nil @registrant_acme.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end
end
