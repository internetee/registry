require "erb"
class WhoisRecord < ActiveRecord::Base
  belongs_to :domain
  belongs_to :registrar

  validates :domain, :name, :body, :json, presence: true

  before_validation :populate
  after_save :update_whois_server
  after_destroy :destroy_whois_record

  class << self
    def included
      includes(
        domain: [
          :registrant,
          :registrar,
          :nameservers,
          { tech_contacts: :registrar },
          { admin_contacts: :registrar }
        ]
      )
    end
  end

  def self.find_by_name(name)
    WhoisRecord.where("lower(name) = ?", name.downcase)
  end

  def generated_json
    @generated_json ||= generate_json
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def generate_json
    h = HashWithIndifferentAccess.new
    return h if domain.blank?

    status_map = {
        'ok' => 'ok (paid and in zone)'
    }

    @disclosed = []
    h[:name]       = domain.name
    h[:status]     = domain.statuses.map { |x| status_map[x] || x }
    h[:registered] = domain.registered_at.try(:to_s, :iso8601)
    h[:changed]    = domain.updated_at.try(:to_s, :iso8601)
    h[:expire]     = domain.valid_to.try(:to_date).try(:to_s)
    h[:outzone]    = domain.outzone_at.try(:to_date).try(:to_s)
    h[:delete]     = [domain.delete_at, domain.force_delete_at].compact.min.try(:to_date).try(:to_s)


    h[:registrant]       = domain.registrant.name
    h[:email] = domain.registrant.email
    @disclosed << [:email, domain.registrant.email]
    h[:registrant_changed]          = domain.registrant.updated_at.try(:to_s, :iso8601)

    h[:admin_contacts] = []
    domain.admin_contacts.each do |ac|
      @disclosed << [:email, ac.email]
      h[:admin_contacts] << {
          name: ac.name,
          email: ac.email,
          changed: ac.updated_at.try(:to_s, :iso8601)
      }
    end
    h[:tech_contacts] = []
    domain.tech_contacts.each do |tc|
      @disclosed << [:email, tc.email]
      h[:tech_contacts] << {
          name: tc.name,
          email: tc.email,
          changed: tc.updated_at.try(:to_s, :iso8601)
      }
    end

    # update registar triggers when adding new attributes
    h[:registrar]         = domain.registrar.name
    h[:registrar_url]     = domain.registrar.url
    h[:registrar_phone]   = domain.registrar.phone
    h[:registrar_address] = domain.registrar.address
    h[:registrar_changed] = domain.registrar.updated_at.try(:to_s, :iso8601)

    h[:nameservers]         = domain.nameservers.pluck(:hostname).uniq.select(&:present?)
    h[:nameservers_changed] = domain.nameservers.pluck(:updated_at).max.try(:to_s, :iso8601)

    h[:dnssec_keys]    = domain.dnskeys.map{|key| "#{key.flags} #{key.protocol} #{key.alg} #{key.public_key}" }
    h[:dnssec_changed] = domain.dnskeys.pluck(:updated_at).max.try(:to_s, :iso8601) rescue nil


    h[:disclosed] = @disclosed # later we can replace
    h
  end

  def generated_body
    template = Rails.root.join("app/views/for_models/whois.erb".freeze)
    ERB.new(template.read, nil, "-").result(binding)
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize


  def populate
    return if domain_id.blank?
    self.json = generated_json
    self.body = generated_body
    self.name = json['name']
    self.registrar_id = domain.registrar_id if domain # for faster registrar updates
  end

  def update_whois_server
    wd = Whois::Record.find_or_initialize_by(name: name)
    wd.body = body
    wd.json = json
    wd.save
  end

  def destroy_whois_record
    Whois::Record.where(name: name).delete_all
  end
end
