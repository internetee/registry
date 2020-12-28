require 'test_helper'
require 'serializers/registrant_api/contact'

class SerializersRegistrantApiContactTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:william)
    @serializer = Serializers::RegistrantApi::Contact.new(@contact, false)
    @json = @serializer.to_json
  end

  def test_returns_uuid_as_id
    assert_equal(@contact.uuid, @json[:id])
  end

  def test_returns_ident_as_separate_object
    expected_ident = { code: @contact.ident, type: @contact.ident_type,
                        country_code: @contact.ident_country_code }
    assert_equal(expected_ident, @json[:ident])
  end

  def test_returns_address_as_separate_object
    expected_address = { street: @contact.street, zip: @contact.zip, city: @contact.city,
                         state: @contact.state, country_code: @contact.country_code }
    assert_equal(expected_address, @json[:address])
  end
end
