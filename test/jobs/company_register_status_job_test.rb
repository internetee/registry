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
        [Company.new('1234567', 'ACME Ltd', REGISTERED)]
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

    assert_not_nil @registrant_acme.checked_company_at
    assert_not_nil @registrant_acme.company_register_status
    assert_not_nil @registrant_jack.checked_company_at
    assert_not_nil @registrant_jack.company_register_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_companies_what_was_checked_before_specific_days_should_be_not_checked
  end

  def test_companies_from_other_countries_are_skipped
  end

  def test_companies_what_was_checked_before_specific_days_should_be_checked
  end

  def test_companies_with_force_delete_and_status_R_should_be_lifted
  end

  def test_companies_with_status_L_should_be_inform_by_email
  end

  def test_companies_with_status_N_should_be_scheduled_for_force_delete
  end

  def test_companies_with_status_K_should_be_scheduled_for_force_delete
  end

  def test_company_information_what_was_not_found_in_register_should_be_deleted
  end

  # def test_contact_who_never_checked_before
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', REGISTERED)]
  #     end
  #     object
  #   end

  #   @registrant_acme.update!(company_register_status: nil, checked_company_at: nil)
  #   @registrant_jack.update!(company_register_status: nil, checked_company_at: nil)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_nil @registrant_acme.checked_company_at
  #   assert_nil @registrant_acme.company_register_status
  #   assert_nil @registrant_jack.checked_company_at
  #   assert_nil @registrant_jack.company_register_status

  #   CompanyRegisterStatusJob.perform_now(14, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_not_nil @registrant_acme.checked_company_at
  #   assert_not_nil @registrant_acme.company_register_status
  #   assert_not_nil @registrant_jack.checked_company_at
  #   assert_not_nil @registrant_jack.company_register_status

  #   CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  # end

  # def test_contact_who_was_checked_some_days_ago
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', REGISTERED)]
  #     end
  #     object
  #   end

  #   interval_days = 14
  #   current_time = Time.zone.now

  #   @registrant_acme.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - (interval_days.days + 1.day))
  #   @registrant_jack.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - (interval_days.days + 2.days))

  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal Contact::REGISTERED, @registrant_acme.company_register_status
  #   assert_equal Contact::REGISTERED, @registrant_jack.company_register_status
  #   assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date
  #   assert_equal current_time.to_date, @registrant_jack.checked_company_at.to_date

  #   CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  # end

  # def test_it_should_not_check_contact_what_days_limit_not_reached
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', REGISTERED)]
  #     end
  #     object
  #   end

  #   interval_days = 14
  #   current_time = Time.zone.now

  #   @registrant_acme.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - (interval_days.days - 1.day))
  #   @registrant_jack.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - (interval_days.days - 2.days))

  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal (current_time - (interval_days.days - 1.day)).to_date, @registrant_acme.checked_company_at.to_date
  #   assert_equal (current_time - (interval_days.days - 2.days)).to_date, @registrant_jack.checked_company_at.to_date

  #   CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  # end

  # def test_contacts_who_has_liquidated_company_status
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', LIQUIDATED)]
  #     end
  #     object
  #   end

  #   interval_days = 5
  #   current_time = Time.zone.now

  #   @registrant_acme.update!(company_register_status: Contact::LIQUIDATED, checked_company_at: current_time - interval_days.days)
  #   @registrant_jack.update!(company_register_status: Contact::LIQUIDATED, checked_company_at: current_time - (interval_days.days + 2.days))

  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal Contact::LIQUIDATED, @registrant_acme.company_register_status
  #   assert_equal Contact::LIQUIDATED, @registrant_jack.company_register_status

  #   assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date
  #   assert_equal current_time.to_date, @registrant_jack.checked_company_at.to_date

  #   CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  # end

  # def test_liquided_and_registered_companies
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', LIQUIDATED)]
  #     end
  #     object
  #   end

  #   interval_days = 5
  #   current_time = Time.zone.now

  #   @registrant_acme.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - interval_days.days)
  #   @registrant_jack.update!(company_register_status: Contact::LIQUIDATED, checked_company_at: current_time - 2.days)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal Contact::LIQUIDATED, @registrant_acme.company_register_status
  #   assert_equal Contact::LIQUIDATED, @registrant_jack.company_register_status

  #   assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date
  #   assert_equal current_time.to_date, @registrant_jack.checked_company_at.to_date

  #   CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  # end

  # def test_put_force_delete_for_bankroupted_companies
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', BANKRUPT)]
  #     end
  #     object
  #   end

  #   interval_days = 5
  #   current_time = Time.zone.now

  #   refute @registrant_acme.domains.any?(&:force_delete_scheduled?)

  #   @registrant_acme.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - interval_days.days)
  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal Contact::BANKRUPT, @registrant_acme.company_register_status
  #   assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date

  #   assert @registrant_acme.domains.all?(&:force_delete_scheduled?)
  # end

  # def test_puts_force_delete_for_deleted_companies
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', DELETED)]
  #     end
  #     object
  #   end

  #   interval_days = 5
  #   current_time = Time.zone.now

  #   refute @registrant_acme.domains.any?(&:force_delete_scheduled?)

  #   @registrant_acme.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - interval_days.days)
  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal Contact::DELETED, @registrant_acme.company_register_status
  #   assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date

  #   assert @registrant_acme.domains.all?(&:force_delete_scheduled?)
  # end

  # def test_should_inform_contact_by_email_if_force_delete_has_been_set
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', DELETED)]
  #     end
  #     object
  #   end

  #   ActionMailer::Base.deliveries.clear
  #   assert_emails 0

  #   interval_days = 5
  #   current_time = Time.zone.now

  #   refute @registrant_acme.domains.any?(&:force_delete_scheduled?)

  #   @registrant_acme.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - interval_days.days)
  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal Contact::DELETED, @registrant_acme.company_register_status
  #   assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date

  #   assert @registrant_acme.domains.all?(&:force_delete_scheduled?)

  #   assert_emails 4
  # end

  # def test_should_inform_contact_by_poll_message_if_force_delete_has_been_set
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', DELETED)]
  #     end
  #     object
  #   end

  #   @registrant_acme.registrar.notifications.destroy_all && @registrant_acme.reload
  #   assert_equal @registrant_acme.registrar.notifications.count, 0

  #   interval_days = 5
  #   current_time = Time.zone.now

  #   refute @registrant_acme.domains.any?(&:force_delete_scheduled?)

  #   @registrant_acme.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - interval_days.days)
  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal Contact::DELETED, @registrant_acme.company_register_status
  #   assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date

  #   assert @registrant_acme.domains.all?(&:force_delete_scheduled?)

  #   assert_equal @registrant_acme.registrar.notifications.count, 2
  # end

  # def test_should_inform_contact_if_his_company_in_liquadation
  #   original_new_method = CompanyRegister::Client.method(:new)
  #   CompanyRegister::Client.define_singleton_method(:new) do
  #     object = original_new_method.call
  #     def object.simple_data(registration_number:)
  #       [Company.new('1234567', 'ACME Ltd', LIQUIDATED)]
  #     end
  #     object
  #   end

  #   ActionMailer::Base.deliveries.clear
  #   assert_emails 0

  #   interval_days = 5
  #   current_time = Time.zone.now

  #   @registrant_acme.update!(company_register_status: Contact::REGISTERED, checked_company_at: current_time - interval_days.days)
  #   @registrant_acme.reload && @registrant_jack.reload

  #   CompanyRegisterStatusJob.perform_now(interval_days, 0, 100, true)

  #   @registrant_acme.reload && @registrant_jack.reload

  #   assert_equal Contact::LIQUIDATED, @registrant_acme.company_register_status
  #   assert_equal current_time.to_date, @registrant_acme.checked_company_at.to_date

  #   mail = ActionMailer::Base.deliveries.first
  #   mail_html = Nokogiri::HTML(mail.html_part.body.decoded)
  #   text = mail_html.css('p')[1].text

  #   assert_equal text, "Eesti Interneti Sihtasutusele (EIS) on äriregistri vahendusel teatavaks saanud, et ettevõtte #{@registrant_jack.name} äriregistrikoodiga #{@registrant_jack.ident} suhtes käib likvideerimismenetlus. Tuletame teile meelde, et tulenevalt .ee domeenireeglitest peab domeeni registreerijaks olema eksisteeriv era- või juriidiline isik. Seega käivitame ettevõtte likvideerimise järel sellele kuuluvate registreeringute kustutusmenetluse. Kustutusmenetluse tulemusena eemaldatakse .ee domeeninimi registrist ning vabaneb kõigile soovijatele taaskord registreerimiseks."
  # end
end
