require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  setup do
    @address = Address.new(street: 'Main Street', zip: '1234', city: 'NY', state: 'NY State',
                           country: 'Germany')
  end

  def test_returns_street
    assert_equal 'Main Street', @address.street
  end

  def test_returns_postal_code
    assert_equal '1234', @address.zip
  end

  def test_returns_city
    assert_equal 'NY', @address.city
  end

  def test_returns_state
    assert_equal 'NY State', @address.state
  end

  def test_returns_country
    assert_equal 'Germany', @address.country
  end

  def test_equality
    assert_not_equal Address.new(street: 'one'), Address.new(street: 'two')
    assert_equal Address.new(street: 'one'), Address.new(street: 'one')
  end

  def test_to_s
    assert_equal 'Main Street, NY, NY State, 1234, Germany', @address.to_s
  end
end