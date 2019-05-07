require "erb"
class WhoisRecord < ActiveRecord::Base
  belongs_to :domain
  belongs_to :registrar

  validates :domain, :name, :json, presence: true

  before_validation :populate
  after_save :update_whois_server
  after_destroy :destroy_whois_record

  def self.find_by_name(name)
    WhoisRecord.where("lower(name) = ?", name.downcase)
  end

  def generated_json
    @generated_json ||= generate_json
  end

  def generate_json
    h = HashWithIndifferentAccess.new
    return h if domain.blank?

    if domain.discarded?
      h[:name] = domain.name
      h[:status] = ['deleteCandidate']
      return h
    end

    status_map = {
        'ok' => 'ok (paid and in zone)'
    }

    registrant = domain.registrant

    h[:disclaimer] = disclaimer_text if disclaimer_text.present?
    h[:name]       = domain.name
    h[:status]     = domain.statuses.map { |x| status_map[x] || x }
    h[:registered] = domain.registered_at.try(:to_s, :iso8601)
    h[:changed]    = domain.updated_at.try(:to_s, :iso8601)
    h[:expire]     = domain.valid_to.to_date.to_s
    h[:outzone]    = domain.outzone_at.try(:to_date).try(:to_s)
    h[:delete] = [domain.delete_date, domain.force_delete_date].compact.min.try(:to_s)

    h[:registrant] = registrant.name
    h[:registrant_kind] = registrant.kind

    if registrant.org?
      h[:registrant_reg_no] = registrant.reg_no
      h[:registrant_ident_country_code] = registrant.ident_country_code
    end

    h[:email] = registrant.email
    h[:registrant_changed]          = registrant.updated_at.try(:to_s, :iso8601)
    h[:registrant_disclosed_attributes] = registrant.disclosed_attributes

    h[:admin_contacts] = []

    domain.admin_contacts.each do |contact|
      h[:admin_contacts] << contact_json_hash(contact)
    end

    h[:tech_contacts] = []

    domain.tech_contacts.each do |contact|
      h[:tech_contacts] << contact_json_hash(contact)
    end

    # update registar triggers when adding new attributes
    h[:registrar]         = domain.registrar.name
    h[:registrar_website] = domain.registrar.website
    h[:registrar_phone]   = domain.registrar.phone
    h[:registrar_address] = domain.registrar.address
    h[:registrar_changed] = domain.registrar.updated_at.try(:to_s, :iso8601)

    h[:nameservers]         = domain.nameservers.hostnames.uniq.select(&:present?)
    h[:nameservers_changed] = domain.nameservers.pluck(:updated_at).max.try(:to_s, :iso8601)

    h[:dnssec_keys]    = domain.dnskeys.map{|key| "#{key.flags} #{key.protocol} #{key.alg} #{key.public_key}" }
    h[:dnssec_changed] = domain.dnskeys.pluck(:updated_at).max.try(:to_s, :iso8601) rescue nil


    h
  end

  def populate
    return if domain_id.blank?
    self.json = generated_json
    self.name = json['name']
    self.registrar_id = domain.registrar_id if domain # for faster registrar updates
  end

  def update_whois_server
    wd = Whois::Record.find_or_initialize_by(name: name)
    wd.json = json
    wd.save
  end

  def destroy_whois_record
    Whois::Record.where(name: name).delete_all
  end

  private

  def disclaimer_text
    Setting.registry_whois_disclaimer
  end

  def contact_json_hash(contact)
    {
      name: contact.name,
      email: contact.email,
      changed: contact.updated_at.try(:to_s, :iso8601),
      disclosed_attributes: contact.disclosed_attributes,
    }
  end
end
