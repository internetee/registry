class Registrar
  class SessionsController < Devise::SessionsController
    before_action :check_ip_restriction
    helper_method :depp_controller?

    def create
      @depp_user = Depp::User.new(depp_user_params)

      if @depp_user.pki && request.env['HTTP_SSL_CLIENT_S_DN_CN'].blank?
        @depp_user.errors.add(:base, :webserver_missing_user_name_directive)
      end

      if @depp_user.pki && request.env['HTTP_SSL_CLIENT_CERT'].blank?
        @depp_user.errors.add(:base, :webserver_missing_client_cert_directive)
      end

      if @depp_user.pki && request.env['HTTP_SSL_CLIENT_S_DN_CN'] == '(null)'
        @depp_user.errors.add(:base, :webserver_user_name_directive_should_be_required)
      end

      if @depp_user.pki && request.env['HTTP_SSL_CLIENT_CERT'] == '(null)'
        @depp_user.errors.add(:base, :webserver_client_cert_directive_should_be_required)
      end

      @api_user = ApiUser.find_by(username: sign_in_params[:username],
                                  plain_text_password: sign_in_params[:password])

      unless @api_user
        @depp_user.errors.add(:base, t(:no_such_user))
        show_error and return
      end

      if @depp_user.pki
        unless @api_user.pki_ok?(request.env['HTTP_SSL_CLIENT_CERT'],
                                 request.env['HTTP_SSL_CLIENT_S_DN_CN'], api: false)
          @depp_user.errors.add(:base, :invalid_cert)
        end
      end

      if @depp_user.errors.none?
        if @api_user.active?
          sign_in_and_redirect(:registrar_user, @api_user)
        else
          @depp_user.errors.add(:base, :not_active)
          show_error and return
        end
      else
        show_error and return
      end
    end

    private

    def depp_controller?
      false
    end

    def find_user_by_idc(idc)
      return User.new unless idc
      ApiUser.find_by(identity_code: idc) || User.new
    end

    def find_user_by_idc_and_allowed(idc)
      return User.new unless idc
      possible_users = ApiUser.where(identity_code: idc) || User.new
      possible_users.each do |selected_user|
        registrar = selected_user.registrar
        if WhiteIp.include_ip?(ip: request.ip, scope: :registrar_area, registrar: registrar)
          return selected_user
        end
      end
    end

    def check_ip_restriction
      ip_restriction = Authorization::RestrictedIP.new(request.ip)
      allowed = ip_restriction.can_access_registrar_area_sign_in_page?
      return if allowed

      render plain: t('registrar.authorization.ip_not_allowed', ip: request.ip)
    end

    def current_ability
      @current_ability ||= Ability.new(current_registrar_user, request.ip)
    end

    def after_sign_in_path_for(_resource_or_scope)
      if can?(:show, :poll)
        registrar_root_path
      else
        registrar_account_path
      end
    end

    def after_sign_out_path_for(_resource_or_scope)
      new_registrar_user_session_path
    end

    def user_for_paper_trail
      current_registrar_user ? current_registrar_user.id_role_username : 'anonymous'
    end

    def depp_user_params
      params = sign_in_params
      params[:tag] = params.delete(:username)
      params.merge!(pki: !(Rails.env.development? || Rails.env.test?))
      params
    end

    def show_error
      logger.error @depp_user.errors.full_messages
      redirect_to new_registrar_user_session_url, alert: @depp_user.errors.full_messages.first
    end
  end
end
