require 'test_helper'

class EppSessionTest < ActiveSupport::TestCase
  def setup
    @epp_session = epp_sessions(:api_bestnames)
  end

  def test_valid
    assert @epp_session.valid?
  end

  def test_invalid_without_session_id
    @epp_session.session_id = nil
    @epp_session.validate
    assert @epp_session.invalid?
  end

  def test_invalid_without_user
    @epp_session.user = nil
    @epp_session.validate
    assert @epp_session.invalid?
  end
end
