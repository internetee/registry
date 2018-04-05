require 'test_helper'

class ContactPostalAddressTest < ActiveSupport::TestCase
  setup do
    @original_address_processing = Setting.address_processing
    @contact = contacts(:john)
  end

  teardown do
    Setting.address_processing = @original_address_processing
  end

  def test_invalid_if_country_code_is_invalid_and_address_processing_is_on
    Setting.address_processing = true
    @contact.country_code = 'invalid'
    assert @contact.invalid?
  end

  def test_valid_if_country_code_is_invalid_and_address_processing_is_off
    Setting.address_processing = false
    @contact.country_code = 'invalid'
    assert @contact.valid?
  end
end
