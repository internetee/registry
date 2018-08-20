require 'test_helper'

class ContactAddressTest < ActiveSupport::TestCase
  setup do
    @address = Contact::Address.new('Main Street', '1234', 'NY City', 'NY State', 'US')
  end

  def test_equal_when_all_parts_are_the_same
    assert_equal @address, Contact::Address.new('Main Street', '1234', 'NY City', 'NY State', 'US')
  end

  def test_not_equal_when_some_part_is_different
    assert_not_equal @address, Contact::Address.new('Main Street', '1234', 'NY City', 'NY State',
                                                    'DE')
  end
end