require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
  end

  def test_valid_fixture
    assert @contact.valid?, proc { @contact.errors.full_messages }
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

  def test_address
    address = Contact::Address.new('new street', '83746', 'new city', 'new state', 'EE')
    @contact.address = address
    @contact.save!
    @contact.reload

    assert_equal 'new street', @contact.street
    assert_equal '83746', @contact.zip
    assert_equal 'new city', @contact.city
    assert_equal 'new state', @contact.state
    assert_equal 'EE', @contact.country_code
    assert_equal address, @contact.address
  end
end
