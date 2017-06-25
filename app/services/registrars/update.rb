module Registrars
  class Update
    attr_reader :registrar

    def initialize(registrar:)
      @registrar = registrar
    end

    def update
      registrar.transaction do
        whois_update_required = whois_update_required?
        registrar.save!
        update_whois if whois_update_required
      end
    end

    private

    def update_whois
      registrar.domains.pluck(:name).each do |domain_name|
        DNS::DomainName.update_whois(domain_name: domain_name)
      end
    end

    def whois_update_required?
      registrar.changed? && (registrar.changes.keys & whois_update_trigger_attributes).present?
    end

    def whois_update_trigger_attributes
      %w(name phone street city state zip website)
    end
  end
end
