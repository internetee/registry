class Epp::SessionsController < EppController
  skip_authorization_check only: [:hello, :login, :logout]

  def hello
    render_epp_response('greeting')
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/MethodLength
  # rubocop: disable Metrics/AbcSize
  def login
    success = true
    @api_user = ApiUser.find_by(login_params)

    if request.ip == ENV['webclient_ip'] && !Rails.env.test? && !Rails.env.development?
      client_md5 = Certificate.parse_md_from_string(request.env['HTTP_SSL_CLIENT_CERT'])
      server_md5 = Certificate.parse_md_from_string(File.read(ENV['cert_path']))
      if client_md5 != server_md5
        @msg = 'Authentication error; server closing connection (certificate is not valid)'
        success = false
      end
    end

    if request.ip != ENV['webclient_ip'] && @api_user
      unless @api_user.api_pki_ok?(request.env['HTTP_SSL_CLIENT_CERT'], request.env['HTTP_SSL_CLIENT_S_DN_CN'])
        @msg = 'Authentication error; server closing connection (certificate is not valid)'
        success = false
      end
    end

    if success && !@api_user
      @msg = 'Authentication error; server closing connection (API user not found)'
      success = false
    end

    if success && !@api_user.try(:active)
      @msg = 'Authentication error; server closing connection (API user is not active)'
      success = false
    end

    if success && !ip_white?
      @msg = 'Authentication error; server closing connection (IP is not whitelisted)'
      success = false
    end

    if success && !connection_limit_ok?
      @msg = 'Authentication error; server closing connection (connection limit reached)'
      success = false
    end

    if success
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
  # rubocop: enable Metrics/MethodLength
  # rubocop: enable Metrics/AbcSize
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def ip_white?
    return true if request.ip == ENV['webclient_ip']
    if @api_user
      return false unless @api_user.registrar.api_ip_white?(request.ip)
    end
    true
  end

  def connection_limit_ok?
    return true if Rails.env.test?
    c = EppSession.where(
      'registrar_id = ? AND updated_at >= ?', @api_user.registrar_id, Time.zone.now - 5.minutes
    ).count

    return false if c >= 4
    true
  end

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
