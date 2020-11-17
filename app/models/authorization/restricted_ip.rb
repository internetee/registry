module Authorization
  class RestrictedIP
    def initialize(ip)
      @ip = ip
    end

    def self.enabled?
      Setting.registrar_ip_whitelist_enabled
    end

    def can_access_registrar_area?(registrar)
      return true unless self.class.enabled?
      logger.info "Checking: #{ip}, registrar: #{registrar}"
      WhiteIp.include_ip?(ip: ip, scope: :registrar_area, registrar: registrar)
    end

    def can_access_registrar_area_sign_in_page?
      return true unless self.class.enabled?
      WhiteIp.include_ip?(ip: ip, scope: :registrar_area, registrar: nil)
    end

    def logger
      Rails.logger
    end

    private

    attr_reader :ip
  end
end
