require 'test_helper'

class VerifyEmailTaskTest < ActiveJob::TestCase

  def setup
    @contact = contacts(:john)
    @invalid_contact = contacts(:invalid_email)

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

  # def test_should_be_verified_duplicate_emails
  #   william = Contact.where(email: "william@inbox.test").count
  #
  #   assert_equal william, 2
  #   assert_equal Contact.all.count, 9
  #   run_task
  #   assert_equal ValidationEvent.count, Contact.count - 1
  # end

  # def test_should_not_affect_to_successfully_verified_emails
  #   assert_equal ValidationEvent.count, 0
  #   run_task
  #   assert_equal ValidationEvent.count, Contact.count - 1 # Contact has duplicate email and it is skip
  #
  #   run_task
  #   assert_equal ValidationEvent.count, Contact.count - 1
  # end

  # def test_should_verify_contact_which_was_not_verified
  #   bestnames = registrars(:bestnames)
  #   assert_equal ValidationEvent.count, 0
  #   run_task
  #   assert_equal ValidationEvent.count, Contact.count - 1 # Contact has duplicate email and it is skip
  #
  #   assert_equal Contact.count, 9
  #   c = Contact.create(name: 'Jeembo',
  #                      email: 'heey@jeembo.com',
  #                      phone: '+555.555',
  #                      ident: '1234',
  #                      ident_type: 'priv',
  #                      ident_country_code: 'US',
  #                      registrar: bestnames,
  #                      code: 'jeembo-01')
  #
  #   assert_equal Contact.count, 10
  #   run_task
  #   assert_equal ValidationEvent.count, Contact.count - 1
  # end

  # def test_should_verify_again_contact_which_has_faield_verification
  #   assert_equal ValidationEvent.count, 0
  #   run_task
  #   assert_equal Contact.count, 9
  #   assert_equal ValidationEvent.count, 8 # Contact has duplicate email and it is skip
  #
  #   contact = contacts(:john)
  #   v = ValidationEvent.find_by(validation_eventable_id: contact.id)
  #   v.update!(success: false)
  #
  #   run_task
  #   assert_equal ValidationEvent.all.count, 9
  # end

  # def test_should_verify_contact_which_has_expired_date_of_verification
  #   expired_date = Time.now - ValidationEvent::VALIDATION_PERIOD - 1.day
  #
  #   assert_equal ValidationEvent.count, 0
  #   run_task
  #   assert_equal Contact.count, 9
  #   assert_equal ValidationEvent.count, 8 # Contact has duplicate email and it is skip
  #
  #   contact = contacts(:john)
  #   v = ValidationEvent.find_by(validation_eventable_id: contact.id)
  #   v.update!(created_at: expired_date)
  #
  #   run_task
  #   assert_equal ValidationEvent.all.count, 9
  # end

  def test_fd_should_not_removed_if_change_email_to_another_invalid_one
    contact = contacts(:john)

    contact.domains.last.schedule_force_delete(type: :soft)
    assert contact.domains.last.force_delete_scheduled?

    contact.update(email: "test@box.test")
    contact.reload

    trumail_results = OpenStruct.new(success: false,
                                     email: contact.email,
                                     domain: "box.tests",
                                     errors: {:mx=>"target host(s) not found"},
                                     )
    Spy.on_instance_method(Actions::EmailCheck, :check_email).and_return(trumail_results)

    1.times do
      run_task
    end

    assert contact.domains.last.force_delete_scheduled?
  end

  def run_task
    perform_enqueued_jobs do
      Rake::Task['verify_email:check_all'].execute
    end
  end
end
