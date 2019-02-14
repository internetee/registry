require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_valid_fixture_is_valid
    assert @domain.valid?
  end

  def test_invalid_fixture_is_invalid
    assert domains(:invalid).invalid?
  end

  def test_domain_name
    domain = Domain.new(name: 'shop.test')
    assert_equal 'shop.test', domain.domain_name.to_s
  end
end
