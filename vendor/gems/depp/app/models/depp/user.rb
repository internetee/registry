module Depp
  class User
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :tag, :password, :pki

    validates :tag, :password, presence: true

    validate :validate_existance_in_server

    def initialize(args = {})
      args.each { |k, v| send(k.to_s + '=', v) }
    end

    def server
      client_cert = File.read(ENV['cert_path'])
      client_key = File.read(ENV['key_path'])
      port = Rails.env.test? ? 701 : ENV['epp_port']

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
    end

    def repp_request(path, params = {})
      client_cert = File.read(ENV['cert_path'])
      client_key = File.read(ENV['key_path'])

      uri = URI.parse("#{ENV['repp_url']}#{path}")
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req.basic_auth tag, password

      res = Net::HTTP.start(uri.hostname, uri.port,
                            use_ssl: (uri.scheme == 'https'),
                            verify_mode: OpenSSL::SSL::VERIFY_NONE,
                            cert: OpenSSL::X509::Certificate.new(client_cert),
                            key: OpenSSL::PKey::RSA.new(client_key)
      ) do |http|
        http.request(req)
      end

      ret = OpenStruct.new(code: res.code)
      ret.parsed_body = JSON.parse(res.body) if res.body.present?

      if ret.parsed_body && ret.parsed_body['error']
        ret.message = ret.parsed_body['error']
      else
        ret.message = res.message
      end

      ret
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
        errors.add(:base, :authorization_error)
      end

      server.close_connection

      rescue OpenSSL::SSL::SSLError
        errors.add(:base, :invalid_cert)
    end
  end
end
