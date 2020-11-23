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
      Rails.logger.info "Checking if Auth::RestrictedIp.enabled: #{self.class.enabled?}"
      return true unless self.class.enabled?
      Rails.logger.info "Checking if registrar area accessible, result: #{WhiteIp.registrar_area.include_ip?(ip)}"
      WhiteIp.registrar_area.include_ip?(ip)
    end

    private

    attr_reader :ip
  end
end
