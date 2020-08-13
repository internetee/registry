# frozen_string_literal: true

module DNS
  class Zone < ApplicationRecord
    validates :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email, :master_nameserver, presence: true
    validates :ttl, :refresh, :retry, :expire, :minimum_ttl, numericality: { only_integer: true }
    validates :origin, uniqueness: true
    after_save :update_whois_record, if: :subzone?
    after_destroy :update_whois_record, if: :subzone?

    before_destroy do
      throw(:abort) if used?
    end

    def self.generate_zonefiles
      pluck(:origin).each do |origin|
        generate_zonefile(origin)
      end
    end

    def self.generate_zonefile(origin)
      filename = "#{origin}.zone"

      STDOUT << "#{Time.zone.now.utc} - Generating zonefile #{filename}\n"

      zf = ActiveRecord::Base.connection.execute(
        "select generate_zonefile('#{origin}')"
      )[0]['generate_zonefile']

      File.open("#{ENV['zonefile_export_dir']}/#{filename}", 'w') { |f| f.write(zf) }

      STDOUT << "#{Time.zone.now.utc} - Successfully generated zonefile #{filename}\n"
    end

    def self.origins
      pluck(:origin)
    end

    def used?
      Domain.uses_zone?(self)
    end

    def to_s
      origin
    end

    def to_partial_path
      'zone'
    end

    def subzone?
      origin.include? '.'
    end

    def update_whois_record
      UpdateWhoisRecordJob.enqueue origin, 'zone'
    end

    def generate_data
      wr = Whois::Record.find_or_initialize_by(name: origin)
      wr.json = generate_json
      wr.save
    end

    def generate_json
      data = {}.with_indifferent_access
      [domain_vars, registrar_vars, registrant_vars].each do |h|
        data.merge!(h)
      end

      data
    end

    def domain_vars
      { disclaimer: Setting.registry_whois_disclaimer, name: origin,
        registered: created_at.try(:to_s, :iso8601), status: ['ok (paid and in zone)'],
        changed: updated_at.try(:to_s, :iso8601), email: Setting.registry_email,
        admin_contacts: [contact_vars], tech_contacts: [contact_vars],
        nameservers: [master_nameserver] }
    end

    def registrar_vars
      { registrar: Setting.registry_juridical_name, registrar_website: Setting.registry_url,
        registrar_phone: Setting.registry_phone }
    end

    def registrant_vars
      { registrant: Setting.registry_juridical_name, registrant_reg_no: Setting.registry_reg_no,
        registrant_ident_country_code: Setting.registry_country_code, registrant_kind: 'org',
        registrant_disclosed_attributes: %w[name email] }
    end

    def contact_vars
      { name: Setting.registry_invoice_contact, email: Setting.registry_email,
        disclosed_attributes: %w[name email] }
    end
  end
end
