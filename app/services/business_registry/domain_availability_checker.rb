module BusinessRegistry
  class DomainAvailabilityChecker
    def self.filter_available(domains)
      reserved_domains = ReservedDomain.where(name: domains).pluck(:name)
      domains - reserved_domains
    end
  end
end
