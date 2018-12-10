require 'test_helper'

class ContactDisclosableTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
    @original_disclosable_attributes = Contact.disclosable_attributes
  end

  teardown do
    Contact.disclosable_attributes = @original_disclosable_attributes
  end

  def test_no_disclosed_attributes_by_default
    assert_empty Contact.new.disclosed_attributes
  end

  def test_disclosable_attributes
    assert_equal %w[name email], Contact.disclosable_attributes
  end

  def test_valid_without_disclosed_attributes
    @contact.disclosed_attributes = []
    assert @contact.valid?
  end

  def test_invalid_when_attribute_is_not_disclosable
    Contact.disclosable_attributes = %w[some disclosable]
    @contact.disclosed_attributes = %w[some undisclosable]

    assert @contact.invalid?
    assert_includes @contact.errors.get(:disclosed_attributes), 'contain unsupported attribute(s)'
  end

  def test_valid_when_attribute_is_disclosable
    Contact.disclosable_attributes = %w[some disclosable]
    @contact.disclosed_attributes = %w[disclosable]
    assert @contact.valid?
  end
end
