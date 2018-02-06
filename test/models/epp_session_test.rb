require 'test_helper'

class EppSessionTest < ActiveSupport::TestCase
  def setup
    @epp_session = epp_sessions(:api_bestnames)
  end

  def test_valid
    assert @epp_session.valid?
  end

  def test_api_user_id_serialization
    epp_session = EppSession.new
    epp_session.session_id = 'test'
    epp_session.registrar = registrars(:bestnames)
    epp_session[:api_user_id] = ActiveRecord::Fixtures.identify(:api_bestnames)
    epp_session.save!
    epp_session.reload

    assert_equal ActiveRecord::Fixtures.identify(:api_bestnames), epp_session[:api_user_id]
  end

  def test_session_id_presence_validation
    @epp_session.session_id = nil
    @epp_session.validate
    assert @epp_session.invalid?
  end
end
