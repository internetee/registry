module DNS
  class DomainName # Same class is also defined by domain_name gem, the dependency of actionmailer
    attr_reader :name

    def self.update_whois(domain_name:)
      new(domain_name).update_whois
    end

    def initialize(name)
      @name = name
    end

    def available?
      !registered?
    end

    def registered?
      registered_domain.present?
    end

    def reserved?
      ReservedDomain.find_by(name: name)
    end

    def disputed?
      Dispute.find_by(domain_name: name)
    end

    def update_whois
      Whois::Record.regenerate(domain_name: self)
    end

    def registered_domain
      Domain.find_by(name: name)
    end
  end
end
