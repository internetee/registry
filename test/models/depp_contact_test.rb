require 'test_helper'
require 'helpers/phone_format_helper_test'

class DeppContactTest < ActiveSupport::TestCase
  include PhoneFormatHelperTest

  setup do
    @depp_contact = Depp::Contact.new
  end

  def test_validates_phone_format
    assert_phone_format(@depp_contact)
  end
end