module WebclientIpHelper
  require 'ipaddr'

  def webclient_ips
    ENV['webclient_ips'].to_s.split(',').map(&:strip)
  end

  def webclient_ip_allowed?(ip)
    Rails.logger.debug "[webclient_ip_allowed?] IP: #{ip}"
    Rails.logger.debug "[webclient_ip_allowed?] Webclient IPs: #{webclient_ips}"
    webclient_ips.any? do |entry|
      begin
        IPAddr.new(entry).include?(ip)
      rescue IPAddr::InvalidAddressError
        ip == entry
      end
    end
  end
end
