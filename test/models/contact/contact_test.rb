require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:john)
  end

  def test_validates
    assert @contact.valid?
  end
end
