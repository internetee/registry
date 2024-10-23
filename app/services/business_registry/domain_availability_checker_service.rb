module BusinessRegistry
  class DomainAvailabilityCheckerService
    def self.filter_available(domains)
      result = Epp::Domain.check_availability(domains)
      available_domains = domains.select { |domain| result.find { |r| r[:name] == domain }[:avail].positive? }

      domains_in_reserved = ReservedDomain.where(name: available_domains).pluck(:name)
      available_domains - domains_in_reserved
    end

    def self.is_domain_available?(domain)
      result = Epp::Domain.check_availability([domain])
      result = result.find { |r| r[:name] == domain }[:avail].positive?

      result && ReservedDomain.find_by(name: domain).nil?
    end
  end
end
