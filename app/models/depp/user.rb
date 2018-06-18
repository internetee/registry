module Depp
  class User
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    include DisableHtml5Validation

    attr_accessor :tag, :password, :pki

    validates :tag, :password, presence: true

    validate :validate_existance_in_server

    def initialize(args = {})
      args.each { |k, v| send(k.to_s + '=', v) }
    end

    def server
      client_cert = File.read(ENV['cert_path'])
      client_key = File.read(ENV['key_path'])
      port = ENV['epp_port'] || '700'

      @server_cache ||= Epp::Server.new({
        server: ENV['epp_hostname'],
        tag: tag,
        password: password,
        port: port,
        cert: OpenSSL::X509::Certificate.new(client_cert),
        key: OpenSSL::PKey::RSA.new(client_key)
      })
    end

    def request(xml)
      Nokogiri::XML(server.request(xml)).remove_namespaces!
      rescue EppErrorResponse => e
        Nokogiri::XML(e.response_xml.to_s).remove_namespaces!
    end

    private

    def validate_existance_in_server
      return if errors.any?
      res = server.open_connection
      unless Nokogiri::XML(res).css('greeting')
        errors.add(:base, :failed_to_open_connection_to_epp_server)
        server.close_connection # just in case
        return
      end

      ex = EppXml::Session.new(cl_trid_prefix: tag)
      xml = ex.login(clID: { value: tag }, pw: { value: password })
      res = server.send_request(xml)

      if Nokogiri::XML(res).css('result').first['code'] != '1000'
        errors.add(:base, Nokogiri::XML(res).css('result').text)
      end

      server.close_connection

      rescue OpenSSL::SSL::SSLError => e
        Rails.logger.error "INVALID CERT: #{e}"
        Rails.logger.error "INVALID CERT DEBUG INFO: epp_hostname: #{ENV['epp_hostname']}," \
          "port: #{ENV['epp_port']}, cert_path: #{ENV['cert_path']}, key_path: #{ENV['key_path']}"
        errors.add(:base, :invalid_cert)
    end
  end
end
