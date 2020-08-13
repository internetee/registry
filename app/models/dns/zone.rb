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
      h = HashWithIndifferentAccess.new

      h[:disclaimer] = Setting.registry_whois_disclaimer if Setting.registry_whois_disclaimer
      h[:name]       = origin
      h[:status]     = ['ok (paid and in zone)']
      h[:registered] = created_at.try(:to_s, :iso8601)
      h[:changed]    = updated_at.try(:to_s, :iso8601)
      h[:expire]     = nil
      h[:outzone]    = nil
      h[:delete] = nil

      h[:registrant] = Setting.registry_juridical_name
      h[:registrant_kind] = 'org'
      h[:registrant_reg_no] = Setting.registry_reg_no
      h[:registrant_ident_country_code] = Setting.registry_country_code

      h[:email] = Setting.registry_email
      h[:registrant_changed] = nil
      h[:registrant_disclosed_attributes] = %w[name email],

      contact = {
        name: Setting.registry_invoice_contact,
        email: Setting.registry_email,
        changed: nil,
        disclosed_attributes: %w[name email],
      }

      h[:admin_contacts] = [contact]

      h[:tech_contacts] = [contact]

      # update registar triggers when adding new attributes
      h[:registrar]         = Setting.registry_juridical_name
      h[:registrar_website] = Setting.registry_url
      h[:registrar_phone]   = Setting.registry_phone
      h[:registrar_changed] = nil

      h[:nameservers]         = [master_nameserver]
      h[:nameservers_changed] = nil

      h[:dnssec_keys]    = []
      h[:dnssec_changed] = nil

      h
    end
  end
end
