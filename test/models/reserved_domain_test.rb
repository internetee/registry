require 'test_helper'

class ReservedDomainTest < ActiveSupport::TestCase
  setup do
    @reserved_domain = reserved_domains(:one)
  end

  def test_fixture_is_valid
    assert @reserved_domain.valid?
  end
end
