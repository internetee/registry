require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def setup
    @domain = domains(:shop)
  end

  def test_valid_fixture
    assert @domain.valid?
  end

  def test_invalid_fixture
    assert domains(:invalid).invalid?
  end
end
