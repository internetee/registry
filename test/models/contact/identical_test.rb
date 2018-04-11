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
    @original_address_processing = Setting.address_processing
    @contact = contacts(:william)
    @identical = contacts(:identical_to_william)
  end

  teardown do
    Setting.address_processing = @original_address_processing
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

  def test_takes_address_into_account_when_address_processing_is_on
    Setting.address_processing = true

    Contact.address_attribute_names.each do |attribute|
      previous_value = @identical.public_send(attribute)
      @identical.update_attribute(attribute, 'other')
      assert_nil @contact.identical(@identical.registrar)
      @identical.update_attribute(attribute, previous_value)
    end
  end

  def test_ignores_address_when_address_processing_is_off
    Setting.address_processing = false

    Contact.address_attribute_names.each do |attribute|
      previous_value = @identical.public_send(attribute)
      @identical.update_attribute(attribute, 'other')
      assert_equal @identical, @contact.identical(@identical.registrar)
      @identical.update_attribute(attribute, previous_value)
    end
  end
end
