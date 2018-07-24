class Epp::SessionsController < EppController
  skip_authorization_check only: [:hello, :login, :logout]

  def hello
    render_epp_response('greeting')
  end

  def login
    success = true
    @api_user = APIUser.find_by(login_params)

    webclient_request = ENV['webclient_ips'].split(',').map(&:strip).include?(request.ip)
    if webclient_request && !Rails.env.test? && !Rails.env.development?
      client_md5 = Certificate.parse_md_from_string(request.env['HTTP_SSL_CLIENT_CERT'])
      server_md5 = Certificate.parse_md_from_string(File.read(ENV['cert_path']))
      if client_md5 != server_md5
        epp_errors << {
          msg: 'Authentication error; server closing connection (certificate is not valid)',
          code: '2501'
        }

        success = false
      end
    end

    if !Rails.env.development? && (!webclient_request && @api_user)
      unless @api_user.api_pki_ok?(request.env['HTTP_SSL_CLIENT_CERT'], request.env['HTTP_SSL_CLIENT_S_DN_CN'])
        epp_errors << {
          msg: 'Authentication error; server closing connection (certificate is not valid)',
          code: '2501'
        }

        success = false
      end
    end

    if success && !@api_user
      epp_errors << {
        msg: 'Authentication error; server closing connection (API user not found)',
        code: '2501'
      }

      success = false
    end

    if success && !@api_user.try(:active)
      epp_errors << {
        msg: 'Authentication error; server closing connection (API user is not active)',
        code: '2501'
      }

      success = false
    end

    if success && @api_user.cannot?(:create, :epp_login)
      epp_errors << {
        msg: 'Authentication error; server closing connection (API user does not have epp role)',
        code: '2501'
      }

      success = false
    end

    if success && !ip_white?
      epp_errors << {
        msg: 'Authentication error; server closing connection (IP is not whitelisted)',
        code: '2501'
      }

      success = false
    end

    if success && EppSession.limit_reached?(@api_user.registrar)
      epp_errors << {
        msg: 'Authentication error; server closing connection (connection limit reached)',
        code: '2501'
      }

      success = false
    end

    if success
      if params[:parsed_frame].css('newPW').first
        unless @api_user.update(password: params[:parsed_frame].css('newPW').first.text)
          response.headers['X-EPP-Returncode'] = '2500'
          handle_errors(@api_user) and return
        end
      end

      epp_session = EppSession.new
      epp_session.session_id = epp_session_id
      epp_session.user = @api_user
      epp_session.save!
      render_epp_response('login_success')
    else
      response.headers['X-EPP-Returncode'] = '2500'
      handle_errors
    end
  end

  def ip_white?
    webclient_request = ENV['webclient_ips'].split(',').map(&:strip).include?(request.ip)
    return true if webclient_request
    if @api_user
      return false unless @api_user.registrar.api_ip_white?(request.ip)
    end
    true
  end

  def logout
    unless signed_in?
      epp_errors << {
        code: 2201,
        msg: 'Authorization error'
      }
      handle_errors
      return
    end

    @api_user = current_user # cache current_user for logging
    epp_session.destroy
    response.headers['X-EPP-Returncode'] = '1500'
    render_epp_response('logout')
  end

  ### HELPER METHODS ###

  def login_params
    user = params[:parsed_frame].css('clID').first.text
    pw = params[:parsed_frame].css('pw').first.text
    { username: user, password: pw }
  end

  private
  def resource
    @api_user
  end
end
