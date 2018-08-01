require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
  end

  def test_valid_fixture
    assert @contact.valid?
  end

  def test_invalid_without_name
    @contact.name = ''
    assert @contact.invalid?
  end
end