module EppRequestable
  extend ActiveSupport::Concern

  included do
    # before_action :validate_epp_user, only: :create
  end

  def create
    result = server.request(request_params[:payload])
    render_success(data: { xml: result.force_encoding('UTF-8') })
  rescue StandardError
    handle_non_epp_errors(nil, I18n.t('errors.messages.epp_conn_error'))
  end

  private

  # def validate_epp_user
  #   return unless handle_hello_request

  #   handle_login_request
  #   server.close_connection
  # rescue OpenSSL::SSL::SSLError => e
  #   Rails.logger.error "INVALID CERT: #{e}"
  #   Rails.logger.error "INVALID CERT DEBUG INFO: epp_hostname: #{ENV['epp_hostname']}," \
  #     "port: #{ENV['epp_port']}, cert_path: #{ENV['cert_path']}, key_path: #{ENV['key_path']}"
  #   handle_non_epp_errors(nil, I18n.t('errors.messages.invalid_cert'))
  # end

  # def handle_hello_request
  #   res = server.open_connection
  #   unless Nokogiri::XML(res).css('greeting')
  #     server.close_connection # just in case
  #     handle_non_epp_errors(nil, I18n.t('errors.messages.failed_epp_conn')) and return false
  #   end
  #   true
  # end

  # def handle_login_request
  #   tag = current_user.username
  #   ex = EppXml::Session.new(cl_trid_prefix: tag)
  #   xml = ex.login(clID: { value: tag }, pw: { value: current_user.plain_text_password })
  #   res = server.send_request(xml)

  #   return if Nokogiri::XML(res).css('result').first['code'] == '1000'

  #   handle_non_epp_errors(nil, Nokogiri::XML(res).css('result').text)
  # end

  def server
    client_cert = File.read(ENV['cert_path'])
    client_key = File.read(ENV['key_path'])
    port = ENV['epp_port'] || 700
    @server ||= Epp::Server.new({ server: ENV['epp_hostname'], tag: current_user.username,
                                  password: current_user.plain_text_password,
                                  port: port,
                                  cert: OpenSSL::X509::Certificate.new(client_cert),
                                  key: OpenSSL::PKey::RSA.new(client_key) })
  end

  def request_params
    params.require(:xml_console).permit(:payload)
  end
end
