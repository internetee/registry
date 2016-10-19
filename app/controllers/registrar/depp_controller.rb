class Registrar::DeppController < RegistrarController # EPP controller
  helper_method :depp_current_user

  rescue_from(Errno::ECONNRESET, Errno::ECONNREFUSED) do |exception|
    logger.error 'COULD NOT CONNECT TO REGISTRY'
    logger.error exception.backtrace.join("\n")
    redirect_to registrar_login_url, alert: t(:no_connection_to_registry)
  end

  before_action :authenticate_user
  def authenticate_user
    redirect_to registrar_login_url and return unless depp_current_user
  end

  def depp_controller?
    true
  end

  def depp_current_user
    return nil unless current_user
    @depp_current_user ||= Depp::User.new(
      tag: current_user.username,
      password: current_user.password
    )
  end

  def response_ok?
    @data.css('result').each do |x|
      success_codes = %(1000, 1001, 1300, 1301)
      return false unless success_codes.include?(x['code'])
    end
    true
  end
end
