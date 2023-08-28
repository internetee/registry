require 'test_helper'

Company = Struct.new(:registration_number, :company_name, :status)

class CompanyRegisterTest < ActiveSupport::TestCase
  def setup
    @acme_ltd = contacts(:acme_ltd)
    @john = contacts(:john)
    @company_register_stub = CompanyRegister::Client.new
  end

  def test_return_company_status
    original_new_method = CompanyRegister::Client.method(:new)
    CompanyRegister::Client.define_singleton_method(:new) do
      object = original_new_method.call
      def object.company_details(registration_number:)
        [Company.new('1234567', 'ACME Ltd', 'R')]
      end
      object
    end

    assert_equal 'registered', @acme_ltd.return_company_status

    CompanyRegister::Client.define_singleton_method(:new, original_new_method)
  end

  def test_return_company_data
    assert_equal 'ACME Ltd', @acme_ltd.return_company_data.first[:company_name]
    assert_equal '1234567', @acme_ltd.return_company_data.first[:registration_number]
  end

  def test_only_org_can_be_checked
    assert_nil @john.return_company_status
  end

  def test_should_return_liquided_value
    @company_register_stub.stub :company_details, [Company.new('1234567', 'ACME Ltd', 'L')] do
      @acme_ltd.stub :company_register, @company_register_stub do
        assert_equal 'liquidated', @acme_ltd.return_company_status
      end
    end
  end
end
