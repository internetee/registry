require 'test_helper'
require 'helpers/phone_format_helper_test'

class ContactTest < ActiveJob::TestCase
  include PhoneFormatHelperTest

  setup do
    @contact = contacts(:john)
    @old_validation_type = Truemail.configure.default_validation_type
  end

  teardown do
    Truemail.configure.default_validation_type = @old_validation_type
  end

  def test_valid_contact_fixture_is_valid
    assert valid_contact.valid?, proc { valid_contact.errors.full_messages }
  end

  def test_invalid_fixture_is_invalid
    assert contacts(:invalid).invalid?
  end

  def test_private_entity
    assert_equal 'priv', Contact::PRIV
  end

  def test_legal_entity
    assert_equal 'org', Contact::ORG
  end

  def test_invalid_without_name
    contact = valid_contact
    contact.name = ''
    assert contact.invalid?
  end

  def test_allowed_and_disallowed_symbols_for_name
    contact = valid_contact
    contact.name = 'MARY ÄNN O’CONNEŽ-ŠUSLIK'
    assert contact.valid?
    contact.name = 'Boğaçhan Çağlayan'
    assert contact.valid?
    contact.name = '# "¤ #" ¤ "?'
    assert contact.invalid?

    contact.country_code = 'FI'
    contact.ident_type = Contact::ORG
    contact.ident = '1234'
    assert contact.valid?
  end

  def test_validates_code_format
    contact = valid_contact.dup
    max_length = 100

    contact.code = '!invalid'
    assert contact.invalid?

    contact.code = 'a' * max_length.next
    assert contact.invalid?

    contact.code = 'foo:bar'
    assert contact.valid?

    contact.code = 'a' * max_length
    assert contact.valid?
  end

  def test_invalid_when_code_is_already_taken
    another_contact = valid_contact
    contact = another_contact.dup

    contact.code = another_contact.code
    assert contact.invalid?

    contact.regenerate_code
    assert contact.valid?
  end

  def test_invalid_without_email
    contact = valid_contact
    contact.email = ''
    assert contact.invalid?
  end

  def test_email_verification_valid
    contact = valid_contact
    contact.email = 'info@internet.ee'
    assert contact.valid?
  end

  # def test_email_verification_regex_error
  #   Truemail.configure.default_validation_type = :regex

  #   contact = valid_contact
  #   contact.email = '`@internet.ee'
  #   assert contact.invalid?
  #   assert_equal I18n.t('activerecord.errors.models.contact.attributes.email.email_regex_check_error'), contact.errors.messages[:email].first
  # end

  def test_invalid_without_phone
    contact = valid_contact
    contact.phone = ''
    assert contact.invalid?
  end

  def test_validates_phone_format
    contact = valid_contact
    assert_phone_format(contact)
  end

  def test_valid_without_address_when_address_processing_id_disabled
    contact = valid_contact

    contact.street = ''
    contact.city = ''
    contact.zip = ''
    contact.country_code = ''

    assert contact.valid?
  end

  def test_address
    Setting.address_processing = true

    address = Contact::Address.new('new street', '83746', 'new city', 'new state', 'EE')
    @contact.address = address
    @contact.save!
    @contact.reload

    assert_equal 'new street', @contact.street
    assert_equal '83746', @contact.zip
    assert_equal 'new city', @contact.city
    assert_equal 'new state', @contact.state
    assert_equal 'EE', @contact.country_code
    assert_equal address, @contact.address
  end

  def test_returns_registrant_user_direct_contacts
    assert_equal Contact::PRIV, @contact.ident_type
    assert_equal '1234', @contact.ident
    assert_equal 'US', @contact.ident_country_code
    registrant_user = RegistrantUser.new(registrant_ident: 'US-1234')

    registrant_user.stub(:companies, []) do
      assert_equal [@contact], Contact.registrant_user_contacts(registrant_user)
      assert_equal [@contact], Contact.registrant_user_direct_contacts(registrant_user)
    end
  end

  def test_returns_registrant_user_indirect_contacts
    @contact.update!(ident_type: Contact::ORG, ident: '1234321')
    assert_equal 'US', @contact.ident_country_code
    registrant_user = RegistrantUser.new(registrant_ident: 'US-1234321')

    registrant_user.stub(:companies, [OpenStruct.new(registration_number: '1234321')]) do
      assert_equal registrant_user.contacts, Contact.registrant_user_contacts(registrant_user)
    end
  end

  def test_contact_is_a_registrant
    assert_equal @contact.becomes(Registrant), domains(:shop).registrant
    assert @contact.registrant?

    make_contact_free_of_domains_where_it_acts_as_a_registrant(@contact)
    assert_not @contact.registrant?
  end

  def test_linked_when_in_use_as_registrant
    Domain.update_all(registrant_id: @contact.id)
    DomainContact.delete_all

    assert @contact.linked?
  end

  def test_linked_when_in_use_as_domain_contact
    Domain.update_all(registrant_id: contacts(:william).id)
    DomainContact.first.update(contact_id: @contact.id)

    assert @contact.linked?
  end

  def test_unlinked_when_not_in_use_as_either_registrant_or_domain_contact
    contact = unlinked_contact
    assert_not contact.linked?
  end

  def test_managed_when_identity_codes_match
    contact = Contact.new(ident: '1234')
    user = RegistrantUser.new(registrant_ident: 'US-1234')
    assert contact.managed_by?(user)
  end

  def test_unmanaged_when_identity_codes_do_not_match
    contact = Contact.new(ident: '1234')
    user = RegistrantUser.new(registrant_ident: 'US-12345')
    assert_not contact.managed_by?(user)
  end

  def test_deletable_when_not_linked
    contact = unlinked_contact
    assert contact.deletable?
  end

  def test_undeletable_when_linked
    assert @contact.linked?
    assert_not @contact.deletable?
  end

  def test_linked_scope_returns_contact_that_acts_as_registrant
    domains(:shop).update!(registrant: @contact.becomes(Registrant))
    assert Contact.linked.include?(@contact), 'Contact should be included'
  end

  def test_linked_scope_returns_contact_that_acts_as_admin_contact
    domains(:shop).admin_contacts = [@contact]
    assert Contact.linked.include?(@contact), 'Contact should be included'
  end

  def test_linked_scope_returns_contact_that_acts_as_tech_contact
    domains(:shop).tech_contacts = [@contact]
    assert Contact.linked.include?(@contact), 'Contact should be included'
  end

  def test_linked_scope_skips_unlinked_contact
    contact = unlinked_contact
    assert_not Contact.linked.include?(contact), 'Contact should be excluded'
  end

  def test_unlinked_scope_returns_unlinked_contact
    contact = unlinked_contact
    assert Contact.unlinked.include?(contact), 'Contact should be included'
  end

  def test_unlinked_scope_skips_contact_that_is_linked_as_registrant
    contact = unlinked_contact
    domains(:shop).update_columns(registrant_id: contact.becomes(Registrant).id)

    assert Contact.unlinked.exclude?(contact), 'Contact should be excluded'
  end

  def test_unlinked_scope_skips_contact_that_is_linked_as_admin_contact
    contact = unlinked_contact
    domains(:shop).admin_contacts = [contact]

    assert Contact.unlinked.exclude?(contact), 'Contact should be excluded'
  end

  def test_unlinked_scope_skips_contact_that_is_linked_as_tech_contact
    contact = unlinked_contact
    domains(:shop).tech_contacts = [contact]

    assert Contact.unlinked.exclude?(contact), 'Contact should be excluded'
  end

  def test_normalizes_country_code
    Setting.address_processing = true
    contact = Contact.new(country_code: 'us')
    contact.validate
    assert_equal 'US', contact.country_code
  end

  def test_linked_scope_returns_contact_that_acts_as_admin_contact
    domains(:shop).admin_contacts = [@contact]
    assert Contact.linked.include?(@contact), 'Contact should be included'
  end

  def test_linked_scope_returns_contact_that_acts_as_tech_contact
    domains(:shop).tech_contacts = [@contact]
    assert Contact.linked.include?(@contact), 'Contact should be included'
  end

  def test_linked_scope_skips_unlinked_contact
    contact = unlinked_contact
    assert_not Contact.linked.include?(contact), 'Contact should be excluded'
  end

  def test_unlinked_scope_returns_unlinked_contact
    contact = unlinked_contact
    assert Contact.unlinked.include?(contact), 'Contact should be included'
  end

  def test_unlinked_scope_skips_contact_that_is_linked_as_registrant
    contact = unlinked_contact
    domains(:shop).update_columns(registrant_id: contact.becomes(Registrant).id)

    assert Contact.unlinked.exclude?(contact), 'Contact should be excluded'
  end

  def test_unlinked_scope_skips_contact_that_is_linked_as_admin_contact
    contact = unlinked_contact
    domains(:shop).admin_contacts = [contact]

    assert Contact.unlinked.exclude?(contact), 'Contact should be excluded'
  end

  def test_unlinked_scope_skips_contact_that_is_linked_as_tech_contact
    contact = unlinked_contact
    domains(:shop).tech_contacts = [contact]

    assert Contact.unlinked.exclude?(contact), 'Contact should be excluded'
  end

  def test_whois_gets_updated_after_contact_save
    @contact.name = 'SomeReallyWeirdRandomTestName'
    domain = @contact.registrant_domains.first

    perform_enqueued_jobs do
      @contact.save!
    end

    assert_equal domain.whois_record.try(:json).try(:[], 'registrant'), @contact.name
  end

  def test_remove_email_whitespaces
    contact = valid_contact
    contact.email = '  test@test.test   '
    contact.save

    assert_equal contact.email, 'test@test.test'
  end

  # def test_verify_email_if_it_changed
  #   # check that email is invalid
  #   assert_equal @contact.validation_events.count, 0

  #   trumail_results = OpenStruct.new(success: false,
  #                                    email: @contact.email,
  #                                    domain: 'box.tests',
  #                                    errors: { mx: 'target host(s) not found' })

  #   runner = Actions::EmailCheck.new(email: @contact.email,
  #                                    validation_eventable: @contact,
  #                                    check_level: 'mx')

  #   runner.stub :call, trumail_results do
  #     3.times do
  #       perform_enqueued_jobs do
  #         VerifyEmailsJob.perform_now(email: @contact.email, check_level: 'mx')
  #       end
  #     end
  #   end

  #   assert_equal @contact.validation_events.count, 3
  #   validation_event = @contact.validation_events.last

  #   assert_equal validation_event.check_level, 'mx'
  #   assert_equal validation_event.success, false

  #   # set force delete to releted contact domain because invlid email
  #   assert @contact.need_to_start_force_delete?

  #   @contact.domains.each do |domain|
  #     domain.schedule_force_delete(type: :soft)
  #   end

  #   # check it
  #   assert @contact.domains.first.force_delete_scheduled?

  #   # change email to valid

  #   Truemail.configure.whitelisted_domains = %w[email.com inbox.test outlook.test]

  #   @contact.email = 'valid@email.com'
  #   @contact.save! && @contact.reload

  #   assert_equal @contact.validation_events.count, 1

  #   perform_enqueued_jobs

  #   # check that force delete is removed

  #   @contact.reload
  #   assert_not @contact.domains.first.force_delete_scheduled?
  # end

  private

  def make_contact_free_of_domains_where_it_acts_as_a_registrant(contact)
    other_contact = contacts(:william)
    assert_not_equal other_contact, contact
    Domain.update_all(registrant_id: other_contact.id)
  end

  def unlinked_contact
    other_contact = contacts(:william)
    assert_not_equal @contact, other_contact
    Domain.update_all(registrant_id: other_contact.id)
    DomainContact.delete_all

    @contact
  end

  def valid_contact
    contacts(:john)
  end
end
