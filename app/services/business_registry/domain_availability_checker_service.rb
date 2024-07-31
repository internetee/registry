module BusinessRegistry
  class DomainAvailabilityCheckerService
    def self.filter_available(domains)
      reserved_domains = ReservedDomain.where(name: domains).pluck(:name)
      domains - reserved_domains
    end
  end
end
