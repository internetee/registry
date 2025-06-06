require 'test_helper'

class VerifyEmailTaskTest < ActiveJob::TestCase
  def setup
    @contact = contacts(:john)
    @invalid_contact = contacts(:invalid_email)
    @registrar = registrars(:bestnames)

    @default_whitelist = Truemail.configure.whitelisted_domains
    @default_blacklist = Truemail.configure.blacklisted_domains
    Truemail.configure.whitelisted_domains = whitelisted_domains
    Truemail.configure.blacklisted_domains = blacklisted_domains
  end

  def teardown
    Truemail.configure.whitelisted_domains = @default_whitelist
    Truemail.configure.blacklisted_domains = @default_blacklist
  end

  def domain(email)
    Mail::Address.new(email).domain
  rescue Mail::Field::IncompleteParseError
    nil
  end

  def whitelisted_domains
    [domain(@contact.email)].reject(&:blank?)
  end

  def blacklisted_domains
    [domain(@invalid_contact.email)].reject(&:blank?)
  end

  def test_should_skip_duplicate_emails
    william_contacts_count = Contact.where(email: 'william@inbox.test').count

    assert_equal william_contacts_count, 2
    assert_equal Contact.count, 9
    run_task
    assert_equal ValidationEvent.count, Contact.count - 1
  end

  def test_should_not_affect_successfully_verified_emails
    assert_equal ValidationEvent.count, 0
    run_task

    assert_equal ValidationEvent.count, Contact.count - 1
    assert_equal ValidationEvent.where(success: true).count, 5
    assert_equal ValidationEvent.where(success: false).count, 3

    run_task
    assert_equal ValidationEvent.where(success: true).count, 5
    assert_equal ValidationEvent.where(success: false).count, 6
  end

  def test_should_verify_contact_email_which_was_not_verified
    ValidationEvent.delete_all
    assert_equal ValidationEvent.count, 0
    
    run_task
    
    assert_equal ValidationEvent.count, Contact.count - 1
    assert_equal Contact.count, 9
    
    assert_difference 'Contact.count', 1 do
      create_valid_contact
    end

    assert_difference 'ValidationEvent.where(success: true).count', 1 do
      run_task
    end
  end

  def test_fd_should_not_be_removed_if_email_changed_to_another_invalid_one
    contact = contacts(:john)

    contact.domains.last.schedule_force_delete(type: :soft)
    assert contact.domains.last.force_delete_scheduled?

    contact.update_attribute(:email, 'test@box.test')
    contact.reload

    trumail_results = OpenStruct.new(success: false,
                                     email: contact.email,
                                     domain: 'box.tests',
                                     errors: { mx: 'target host(s) not found' })
    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)

    run_task

    assert contact.domains.last.force_delete_scheduled?
  end

  def test_should_remove_old_validation_records
    trumail_results = OpenStruct.new(success: false,
                                     email: @contact.email,
                                     domain: 'box.tests',
                                     errors: { mx: 'target host(s) not found' })

    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)
    Spy.on_instance_method(Actions::AAndAaaaEmailValidation, :call).and_return([true])

    Actions::EmailCheck.new(email: @contact.email,
                            validation_eventable: @contact,
                            check_level: 'regex').call

    travel_to(Time.zone.now + ::ValidationEvent::VALIDATION_PERIOD + 1.minute)
    assert_equal ValidationEvent.old_records.count, 1

    run_task

    assert_predicate ValidationEvent.old_records.count, :zero?
  end

  def run_task
    perform_enqueued_jobs do
      Rake::Task['verify_email:check_all'].execute
    end
  end

  def create_valid_contact
    Contact.create!(name: 'Jeembo',
                    email: 'heey@jeembo.com',
                    phone: '+555.555',
                    ident: '1234',
                    ident_type: 'priv',
                    ident_country_code: 'US',
                    registrar: @registrar,
                    code: 'jeembo-01')
  end
end
