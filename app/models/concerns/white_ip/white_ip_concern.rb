# app/models/concerns/white_ip_concern.rb
module WhiteIp::WhiteIpConcern
  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength
    def include_ip?(ip)
      return false if ip.blank?

      where(id: ids_including(ip)).any?
    end

    def ids_including(ip)
      ipv4 = select_ipv4(ip)
      ipv6 = select_ipv6(ip)

      (ipv4 + ipv6).pluck(:id).flatten.uniq
    end

    # rubocop:disable Style/CaseEquality
    def select_ipv4(ip)
      return [] if check_ip4(ip).blank?

      select { |white_ip| check_ip4(white_ip.ipv4) === check_ip4(ip) }
    end

    def select_ipv6(ip)
      return [] if check_ip6(ip).blank?

      select { |white_ip| check_ip6(white_ip.ipv6) === check_ip6(ip) }
    end
    # rubocop:enable Style/CaseEquality

    def csv_header
      %w[IPv4 IPv6 Interfaces Created Updated]
    end

    def ransackable_attributes(*)
      authorizable_ransackable_attributes
    end

    def check_ip4(ip)
      IPAddr.new(ip, Socket::AF_INET)
    rescue StandardError => _e
      nil
    end

    def check_ip6(ip)
      IPAddr.new(ip, Socket::AF_INET6)
    rescue StandardError => _e
      nil
    end
  end
end
