require 'test_helper'

class ContactIdenticalTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:william)
    @identical = contacts(:identical_to_william)
  end

  def test_identical
    assert_equal @identical, @contact.identical(@identical.registrar)
  end

  def test_not_identical
    filter_attributes = %i[
      name
      ident
      ident_type
      ident_country_code
      phone
      email
    ]

    filter_attributes.each do |attribute|
      previous_value = @identical.public_send(attribute)
      @identical.update_attribute(attribute, 'other')
      assert_nil @contact.identical(@identical.registrar)
      @identical.update_attribute(attribute, previous_value)
    end
  end
end
