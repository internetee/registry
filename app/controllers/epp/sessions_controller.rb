class Epp::SessionsController < ApplicationController
  include Epp::Common
  layout false

  private

  def hello
    render_epp_response('greeting')
  end

  def login
    @epp_user = EppUser.find_by(login_params)

    if @epp_user.try(:active)
      epp_session[:epp_user_id] = @epp_user.id
      render_epp_response('login_success')
    else
      response.headers['X-EPP-Returncode'] = '2200'
      render_epp_response('login_fail')
    end
  end

  def logout
    @epp_user = current_epp_user # cache current_epp_user for logging
    epp_session[:epp_user_id] = nil
    response.headers['X-EPP-Returncode'] = '1500'
    render_epp_response('logout')
  end

  ### HELPER METHODS ###

  def login_params
    ph = params_hash['epp']['command']['login']
    { username: ph[:clID], password: ph[:pw] }
  end
end
