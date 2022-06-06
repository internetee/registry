require 'test_helper'

class RegistrantUserTest < ActiveSupport::TestCase
  Company = Struct.new(:registration_number, :company_name)

  def setup
    super

    @user = users(:registrant)
  end

  def teardown
    super
  end

  def test_ident_helper_method
    assert_equal('1234', @user.ident)
  end

  def test_first_name_from_username
    user = RegistrantUser.new(username: 'John Doe')
    assert_equal 'John', user.first_name
  end

  def test_last_name_from_username
    user = RegistrantUser.new(username: 'John Doe')
    assert_equal 'Doe', user.last_name
  end

  def test_returns_country
    user = RegistrantUser.new(registrant_ident: 'US-1234')
    assert_equal Country.new('US'), user.country
  end

  def test_should_update_contacts_if_names_dismatch
    assert_equal 'US-1234', @user.registrant_ident
    registrars = [registrars(:bestnames), registrars(:goodnames)]
    contacts = [contacts(:john), contacts(:william), contacts(:identical_to_william),
                contacts(:acme_ltd), contacts(:registrar_ltd)]
    contacts.each do |c|
      if c.ident_type == 'priv'
        c.ident = @user.ident
      else
        c.ident_country_code = 'EE'
        c.registrar = registrars(:bestnames)
      end
      c.save(validate: false)
    end

    company_one = Company.new(contacts(:acme_ltd).ident, 'ace')
    company_two = Company.new(contacts(:registrar_ltd).ident, 'acer')

    Spy.on(@user, :companies).and_return([company_one, company_two])
    @user.update_contacts

    contacts.each do |c|
      c.reload
      assert_equal @user.username, c.name if c.ident_type == 'priv'
      assert @user.actions.find_by(operation: :update, contact_id: c.id)
    end

    bulk_action = @user.actions.where(operation: :bulk_update).last
    single_action = @user.actions.find_by(operation: :update,
                                   contact_id: contacts(:identical_to_william).id)

    assert_equal 4, bulk_action.subactions.size

    registrars.each do |r|
      notification = r.notifications.unread.order('created_at DESC').take
      if r == registrars(:bestnames)
        assert_equal '4 contacts have been updated by registrant', notification.text
        assert_equal 'ContactUpdateAction', notification.attached_obj_type
        assert_equal bulk_action.id, notification.attached_obj_id
        assert_equal bulk_action.id, notification.action_id
      else
        assert_equal 'Contact william-002 has been updated by registrant', notification.text
        assert_equal 'ContactUpdateAction', notification.attached_obj_type
        assert_equal single_action.id, notification.attached_obj_id
        assert_equal single_action.id, notification.action_id
      end
    end
  end

  def test_queries_company_register_for_associated_companies
    assert_equal 'US-1234', @user.registrant_ident

    company = Company.new('acme', 'ace')

    company_register = Minitest::Mock.new
    company_register.expect(:representation_rights, [company], [{ citizen_personal_code: '1234',
                                                                  citizen_country_code: 'USA' }])

    assert_equal [company], @user.companies(company_register)
    company_register.verify
  end

  def test_should_return_zero_count_of_companies
    assert_equal 'US-1234', @user.registrant_ident
    contacts = [contacts(:john), contacts(:william), contacts(:identical_to_william),
                contacts(:acme_ltd), contacts(:registrar_ltd)]

    contacts.each do |c|
      if c.ident_type == 'priv'
        c.ident = @user.ident
        c.name = @user.username
      else
        c.ident_country_code = 'EE'
      end
      c.save(validate: false)
    end

    company_one = Company.new(contacts(:acme_ltd).ident, 'Acme Ltd')
    company_two = Company.new(contacts(:registrar_ltd).ident, 'Registrar Ltd')

    Spy.on(@user, :companies).and_return([company_one, company_two])
    response = @user.do_need_update_contacts?

    assert_equal response[:counter], 0
  end

  def test_should_return_count_of_contacts_which_should_be_updated
    assert_equal 'US-1234', @user.registrant_ident
    contacts = [contacts(:john), contacts(:william), contacts(:identical_to_william),
                contacts(:acme_ltd), contacts(:registrar_ltd)]
    contacts.each do |c|
      if c.ident_type == 'priv'
        c.ident = @user.ident
      else
        c.ident_country_code = 'EE'
      end
      c.save(validate: false)
    end

    company_one = Company.new(contacts(:acme_ltd).ident, 'ace')
    company_two = Company.new(contacts(:registrar_ltd).ident, 'acer')

    Spy.on(@user, :companies).and_return([company_one, company_two])
    response = @user.do_need_update_contacts?

    assert_equal response[:counter], 5
  end

  def test_returns_contacts
    Contact.stub(:registrant_user_contacts, %w[john jane]) do
      assert_equal %w[john jane], @user.contacts
    end
  end

  def test_returns_direct_contacts
    Contact.stub(:registrant_user_direct_contacts, %w[john jane]) do
      assert_equal %w[john jane], @user.direct_contacts
    end
  end

  def test_returns_domains
    Domain.stub(:registrant_user_domains, %w[shop airport]) do
      assert_equal %w[shop airport], @user.domains
    end
  end

  def test_returns_administered_domains
    Domain.stub(:registrant_user_administered_domains, %w[shop airport]) do
      assert_equal %w[shop airport], @user.administered_domains
    end
  end
end
