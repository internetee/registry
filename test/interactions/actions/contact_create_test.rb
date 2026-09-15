require 'test_helper'

class Actions::ContactCreateTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:acme_ltd)
    @contact.ident_country_code = 'EE'
    @ident = { ident: @contact.ident,
               ident_type: @contact.ident_type,
               ident_country_code: @contact.ident_country_code }
  end

  teardown do
    Setting.validate_business_contacts = 'true'
  end

  def test_maybe_company_is_relevant_returns_true_when_toggle_disabled
    Setting.validate_business_contacts = 'false'

    @contact.stub :return_company_status, ->(*) { flunk 'company register must not be called' } do
      action = Actions::ContactCreate.new(@contact, nil, @ident)
      assert_equal true, action.maybe_company_is_relevant
    end

    epp_msgs = @contact.errors.where(:epp_errors).map { |e| e.options[:msg] }
    assert_empty epp_msgs
  end

  def test_maybe_company_is_relevant_checks_register_when_toggle_enabled_and_company_registered
    Setting.validate_business_contacts = 'true'

    @contact.stub :return_company_status, Contact::REGISTERED do
      action = Actions::ContactCreate.new(@contact, nil, @ident)
      assert_equal true, action.maybe_company_is_relevant
    end
  end

  def test_maybe_company_is_relevant_adds_error_when_toggle_enabled_and_company_missing
    Setting.validate_business_contacts = 'true'

    @contact.stub :return_company_status, 'N' do
      action = Actions::ContactCreate.new(@contact, nil, @ident)
      action.maybe_company_is_relevant
      error_texts = @contact.errors.where(:epp_errors).map { |e| e.options[:msg] }
      assert(error_texts.any? { |msg| msg.to_s.include?(I18n.t('errors.messages.company_not_registered')) })
    end
  end
end
