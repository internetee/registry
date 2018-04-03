require 'test_helper'

class ContactIdenticalTest < ActiveSupport::TestCase
  REGULAR_FILTER_ATTRIBUTES = %i[
    name
    email
    phone
    fax
    ident
    ident_type
    ident_country_code
    org_name
  ]

  setup do
    @contact = contacts(:william)
    @identical = contacts(:identical_to_william)
  end

  def test_returns_identical
    assert_equal @identical, @contact.identical(@identical.registrar)
  end

  def test_does_not_return_non_identical
    REGULAR_FILTER_ATTRIBUTES.each do |attribute|
      previous_value = @identical.public_send(attribute)
      @identical.update_attribute(attribute, 'other')
      assert_nil @contact.identical(@identical.registrar)
      @identical.update_attribute(attribute, previous_value)
    end

    @identical.update!({ statuses: %w[ok linked] })
    assert_nil @contact.identical(@identical.registrar)
  end

  def test_takes_address_into_account_when_processing_enabled
    Contact.address_attribute_names.each do |attribute|
      previous_value = @identical.public_send(attribute)
      @identical.update_attribute(attribute, 'other')

      Contact.stub :address_processing?, true do
        assert_nil @contact.identical(@identical.registrar)
      end

      @identical.update_attribute(attribute, previous_value)
    end
  end

  def test_ignores_address_when_processing_disabled
    Setting.address_processing = false

    Contact.address_attribute_names.each do |attribute|
      previous_value = @identical.public_send(attribute)
      @identical.update_attribute(attribute, 'other')

      Contact.stub :address_processing?, false do
        assert_equal @identical, @contact.identical(@identical.registrar)
      end

      @identical.update_attribute(attribute, previous_value)
    end
  end
end
