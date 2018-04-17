require 'test_helper'

class DomainDeletableTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_discard
    refute @domain.discarded?
    @domain.discard
    @domain.reload
    assert @domain.discarded?
  end
end
