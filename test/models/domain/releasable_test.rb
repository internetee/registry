require 'test_helper'

class DomainReleasableTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_releasing_a_domain_discards_it_by_default
    refute Domain.release_to_auction
  end
end
