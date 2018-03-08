require 'test_helper'

class ContactPostalAddressTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:john)
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
