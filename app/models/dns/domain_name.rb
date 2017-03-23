module DNS
  class DomainName # Same class is also defined by domain_name gem, the dependency of actionmailer
    def self.update_whois(domain_name:)
      new(domain_name).update_whois
    end

    def initialize(name)
      @name = name
    end

    def update_whois
      #Whois::Record.regenerate!(domain_name: domain_name)
    end

    def available?
      domain.nil?
    end

    def registered?
      !available?
    end

    private

    def domain
      Domain.find_by(name: name)
    end

    attr_reader :name
  end
end
