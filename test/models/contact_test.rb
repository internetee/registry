require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:john)
    @original_address_processing_setting = Setting.address_processing
  end

  def teardown
    Setting.address_processing = @original_address_processing_setting
  end

  def test_valid_fixture
    assert @contact.valid?
  end

  def test_email_validation
    @contact.email = ''
    assert @contact.invalid?

    @contact.email = 'test@bestmail.test'
    assert @contact.valid?
  end

  def test_phone_validation
    @contact.phone = ''
    assert @contact.invalid?

    @contact.phone = '+123.'
    assert @contact.invalid?

    @contact.phone = '+123.4'
    assert @contact.valid?
  end
end