module Whois
  class Record::JSONRegistered
    def initialize(domain_name:)
      @domain_name = domain_name
    end

    def generate
      h = HashWithIndifferentAccess.new

      status_map = {
        'ok' => 'ok (paid and in zone)'
      }

      registrant = domain.registrant

      @disclosed = []
      h[:name] = domain.name
      h[:status] = domain.statuses.map { |x| status_map[x] || x }
      h[:registered] = domain.registered_at.try(:to_s, :iso8601)
      h[:changed] = domain.updated_at.try(:to_s, :iso8601)
      h[:expire] = domain.valid_to.try(:to_date).try(:to_s)
      h[:outzone] = domain.outzone_at.try(:to_date).try(:to_s)
      h[:delete] = [domain.delete_at, domain.force_delete_at].compact.min.try(:to_date).try(:to_s)

      h[:registrant] = registrant.name
      h[:registrant_kind] = registrant.kind

      if registrant.org?
        h[:registrant_reg_no] = registrant.reg_no
        h[:registrant_ident_country_code] = registrant.ident_country_code
      end

      h[:email] = registrant.email
      @disclosed << [:email, registrant.email]
      h[:registrant_changed] = registrant.updated_at.try(:to_s, :iso8601)

      h[:admin_contacts] = []
      domain.admin_contacts.each do |ac|
        @disclosed << [:email, ac.email]
        h[:admin_contacts] << {
          'name' => ac.name,
          'email' => ac.email,
          'changed' => ac.updated_at.try(:to_s, :iso8601)
        }
      end

      h[:tech_contacts] = []
      domain.tech_contacts.each do |tc|
        @disclosed << [:email, tc.email]
        h[:tech_contacts] << {
          'name' => tc.name,
          'email' => tc.email,
          'changed' => tc.updated_at.try(:to_s, :iso8601)
        }
      end

      h[:registrar] = domain.registrar.name
      h[:registrar_website] = domain.registrar.website
      h[:registrar_phone] = domain.registrar.phone
      h[:registrar_address] = domain.registrar.address
      h[:registrar_changed] = domain.registrar.updated_at.try(:to_s, :iso8601)

      h[:nameservers] = domain.nameservers.hostnames.uniq.select(&:present?)
      h[:nameservers_changed] = domain.nameservers.pluck(:updated_at).max.try(:to_s, :iso8601)

      h[:dnssec_keys] = domain.dnskeys.map { |key| "#{key.flags} #{key.protocol} #{key.alg} #{key.public_key}" }
      h[:dnssec_changed] = domain.dnskeys.pluck(:updated_at).max.try(:to_s, :iso8601) rescue nil


      h[:disclosed] = @disclosed
      h
    end

    private

    attr_reader :domain_name

    def domain
      domain_name.registered_domain
    end
  end
end
