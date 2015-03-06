class Epp::SessionsController < EppController
  skip_authorization_check only: [:hello, :login, :logout]

  def hello
    render_epp_response('greeting')
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def login
    cert_valid = true
    if request.ip == ENV['webclient_ip']
      @api_user = ApiUser.find_by(login_params)
    else
      if request.env['HTTP_SSL_CLIENT_S_DN_CN'] != login_params[:username]
        cert_valid = false
      end
      @api_user = ApiUser.find_by(login_params)
    end

    if @api_user.try(:active) && cert_valid
      epp_session[:api_user_id] = @api_user.id
      render_epp_response('login_success')
    else
      response.headers['X-EPP-Returncode'] = '2200'
      render_epp_response('login_fail')
    end
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

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
