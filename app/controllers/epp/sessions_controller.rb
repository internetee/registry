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

    if @api_user.try(:active) && cert_valid && ip_white? && connection_limit_ok?
      if parsed_frame.css('newPW').first
        unless @api_user.update(password: parsed_frame.css('newPW').first.text)
          response.headers['X-EPP-Returncode'] = '2200'
          handle_errors(@api_user) and return
        end
      end

      epp_session[:api_user_id] = @api_user.id
      epp_session.update_column(:registrar_id, @api_user.registrar_id)
      render_epp_response('login_success')
    else
      response.headers['X-EPP-Returncode'] = '2200'
      render_epp_response('login_fail')
    end
  end

  def ip_white?
    return true if request.ip == ENV['webclient_ip']
    if @api_user
      unless @api_user.registrar.api_ip_white?(request.ip)
        @msg = t('ip_is_not_whitelisted')
        return false
      end
    end
    true
  end

  def connection_limit_ok?
    c = EppSession.where(
      'registrar_id = ? AND updated_at >= ?', @api_user.registrar_id, Time.zone.now - 5.minutes
    ).count

    if c >= 4
      @msg = t('connection_limit_reached')
      return false
    end
    true
  end

  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def logout
    @api_user = current_user # cache current_user for logging
    epp_session.destroy
    response.headers['X-EPP-Returncode'] = '1500'
    render_epp_response('logout')
  end

  ### HELPER METHODS ###

  def login_params
    ph = params_hash['epp']['command']['login']
    { username: ph[:clID], password: ph[:pw] }
  end

  def parsed_frame
    @parsed_frame ||= Nokogiri::XML(request.params[:raw_frame]).remove_namespaces!
  end
end
