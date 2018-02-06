require 'test_helper'

class EppSessionTest < ActiveSupport::TestCase
  def test_api_user_id_serialization
    epp_session = EppSession.new
    epp_session.registrar = registrars(:bestnames)
    epp_session[:api_user_id] = ActiveRecord::Fixtures.identify(:api_bestnames)
    epp_session.save!
    epp_session.reload

    assert_equal ActiveRecord::Fixtures.identify(:api_bestnames), epp_session[:api_user_id]
  end
end
