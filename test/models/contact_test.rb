require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
    @original_address_processing_setting = Setting.address_processing
  end

  def teardown
    Setting.address_processing = @original_address_processing_setting
  end

  def test_valid_fixture
    assert @contact.valid?
  end

  def test_invalid_without_email
    @contact.email = ''
    assert @contact.invalid?
  end

  def test_email_format_validation
    @contact.email = 'invalid'
    assert @contact.invalid?

    @contact.email = 'test@bestmail.test'
    assert @contact.valid?
  end

  def test_invalid_without_phone
    @contact.email = ''
    assert @contact.invalid?
  end

  def test_phone_format_validation
    @contact.phone = '+123.'
    assert @contact.invalid?

    @contact.phone = '+123.4'
    assert @contact.valid?
  end
end