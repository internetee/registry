require 'test_helper'

class OrgRegistrantPhoneCheckerJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @contact = contacts(:acme_ltd)
    @original_phone = '+372.555666777'
    @contact.update!(
      phone: @original_phone,
      ident_type: 'org',
      ident_country_code: 'EE',
      ident: '12345678'
    )
    
    ENV['SKIP_COMPANY_REGISTER_CACHE'] = 'true'
    Rails.cache.clear if defined?(Rails.cache)
  end
  
  teardown do
    ENV['SKIP_COMPANY_REGISTER_CACHE'] = nil
  end

  def test_bulk_checker_processes_all_ee_org_contacts
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.company_details(registration_number:)
        [OpenStruct.new(phone_numbers: ['+372.555666777'])]
      end
      object
    end

    assert_not @contact.disclosed_attributes.include?('phone')
    
    OrgRegistrantPhoneCheckerJob.perform_now(type: 'bulk')
    @contact.reload

    assert @contact.disclosed_attributes.include?('phone')

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_single_checker_processes_specific_contact
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.company_details(registration_number:)
        [OpenStruct.new(phone_numbers: ['+372.555666777'])]
      end
      object
    end

    assert_not @contact.disclosed_attributes.include?('phone')
    
    OrgRegistrantPhoneCheckerJob.perform_now(
      type: 'single',
      registrant_user_code: @contact.code
    )
    @contact.reload

    assert @contact.disclosed_attributes.include?('phone')

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_removes_phone_disclosure_when_numbers_do_not_match
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.company_details(registration_number:)
        [OpenStruct.new(phone_numbers: ['+372.999888777'])]
      end
      object
    end

    @contact.disclosed_attributes = ['phone']
    @contact.save!
    assert @contact.disclosed_attributes.include?('phone')
    
    OrgRegistrantPhoneCheckerJob.perform_now(type: 'bulk')
    @contact.reload

    assert_not @contact.disclosed_attributes.include?('phone')

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_handles_invalid_job_type
    assert_raises(RuntimeError) do
      OrgRegistrantPhoneCheckerJob.perform_now(type: 'invalid')
    end
  end

  def test_phone_number_formatting_matches_different_formats
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.company_details(registration_number:)
        [OpenStruct.new(phone_numbers: ['+372 555 666 777'])]
      end
      object
    end

    @contact.phone = '+372.555666777'
    @contact.save(validate: false)
    assert_not @contact.disclosed_attributes.include?('phone')
    
    OrgRegistrantPhoneCheckerJob.perform_now(type: 'bulk')
    @contact.reload

    assert @contact.disclosed_attributes.include?('phone')

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end
  
  # Test that successfully retries after a connection error
  def test_retries_and_recovers_from_connection_error
    call_count = 0
    
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.company_details(registration_number:)
        parent_call_count = CompanyRegister::Client.class_variable_get(:@@test_call_count)
        parent_call_count += 1
        CompanyRegister::Client.class_variable_set(:@@test_call_count, parent_call_count)
        
        if parent_call_count == 1
          raise HTTPClient::KeepAliveDisconnected, "Connection error"
        end
        
        [OpenStruct.new(phone_numbers: ['+372.555666777'])]
      end
      object
    end
    
    CompanyRegister::Client.class_variable_set(:@@test_call_count, 0)
    
    @contact.disclosed_attributes = []
    @contact.save!
    OrgRegistrantPhoneCheckerJob.perform_now(type: 'single', registrant_user_code: @contact.code)
    @contact.reload
    
    assert @contact.disclosed_attributes.include?('phone')
    assert_operator CompanyRegister::Client.class_variable_get(:@@test_call_count), :>=, 2
    
    CompanyRegister::Client.remove_class_variable(:@@test_call_count)
    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end
  
  def test_returns_empty_array_when_max_retries_exceeded
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.company_details(registration_number:)
        raise HTTPClient::KeepAliveDisconnected, "Persistent connection error"
      end
      object
    end
    
    @contact.disclosed_attributes = ['phone']
    @contact.save!
    OrgRegistrantPhoneCheckerJob.perform_now(type: 'single', registrant_user_code: @contact.code)
    @contact.reload

    assert_not @contact.disclosed_attributes.include?('phone')

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end
end 