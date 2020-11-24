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
      registrar.white_ips.registrar_area.include_ip?(ip)
    end

    def can_access_registrar_area_sign_in_page?
      return true unless self.class.enabled?
      WhiteIp.registrar_area.include_ip?(ip)
    end

    private

    attr_reader :ip
  end
end
