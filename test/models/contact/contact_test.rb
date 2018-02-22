require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:john)
  end

  def test_valid_fixture_is_valid
    assert @contact.valid?
  end

  def test_invalid_fixture_is_invalid
    assert contacts(:invalid).invalid?
  end
end
