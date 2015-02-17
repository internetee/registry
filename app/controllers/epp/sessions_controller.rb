class Epp::SessionsController < EppController
  skip_authorization_check only: [:hello, :login, :logout]

  def hello
    render_epp_response('greeting')
  end

  def login
    @api_user = ApiUser.find_by(login_params)

    if @api_user.try(:active)
      epp_session[:api_user_id] = @api_user.id
      render_epp_response('login_success')
    else
      response.headers['X-EPP-Returncode'] = '2200'
      render_epp_response('login_fail')
    end
  end

  def logout
    @api_user = current_user # cache current_user for logging
    epp_session[:api_user_id] = nil
    response.headers['X-EPP-Returncode'] = '1500'
    render_epp_response('logout')
  end

  ### HELPER METHODS ###

  def login_params
    ph = params_hash['epp']['command']['login']
    { username: ph[:clID], password: ph[:pw] }
  end
end
