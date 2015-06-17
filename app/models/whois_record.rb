class WhoisRecord < ActiveRecord::Base
  belongs_to :domain
  belongs_to :registrar

  validates :domain, :name, :body, :json, presence: true

  before_validation :populate
  def populate
    return if domain_id.blank?
    self.json = generate_json
    self.body = generated_body
    self.name = json['name']
    self.registrar_id = domain.registrar_id # for faster registrar updates
  end

  after_save :update_whois_server

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

  # rubocop:disable Metrics/MethodLength
  def generate_json
    h = HashWithIndifferentAccess.new
    return h if domain.blank?

    status_map = {
      'ok' => 'ok (paid and in zone)'
    }

    @disclosed = []
    h[:name] = domain.name
    h[:registrant] = domain.registrant.name
    h[:status] = domain.statuses.map { |x| status_map[x] || x }.join(', ')
    h[:registered] = domain.registered_at.try(:to_s, :iso8601)
    h[:updated_at] = domain.updated_at.try(:to_s, :iso8601)
    h[:valid_to] = domain.valid_to.try(:to_s, :iso8601)

    # update registar triggers when adding new attributes
    h[:registrar] = domain.registrar.name
    h[:registrar_phone] = domain.registrar.phone
    h[:registrar_address] = domain.registrar.address
    h[:registrar_update_at] = domain.registrar.updated_at.try(:to_s, :iso8601)

    h[:admin_contacts] = []
    domain.admin_contacts.each do |ac|
      @disclosed << [:email, ac.email]
      h[:admin_contacts] << {
        name: ac.name,
        email: ac.email,
        registrar: ac.registrar.name,
        created_at: ac.created_at.try(:to_s, :iso8601)
      }
    end
    h[:tech_contacts] = []
    domain.tech_contacts.each do |tc|
      @disclosed << [:email, tc.email]
      h[:tech_contacts] << {
        name: tc.name,
        email: tc.email,
        registrar: tc.registrar.name,
        created_at: tc.created_at.try(:to_s, :iso8601)
      }
    end
    h[:nameservers] = []
    domain.nameservers.each do |ns|
      h[:nameservers] << {
        hostname: ns.hostname,
        updated_at: ns.updated_at.try(:to_s, :iso8601)
      }
    end
    h[:disclosed] = @disclosed
    h
  end

  def generated_body
    <<-EOS
Estonia .ee Top Level Domain WHOIS server

Domain:
  name:       #{json['name']}
  registrant: #{json['registrant']}
  status:     #{json['status']}
  registered: #{Time.zone.parse(json['registered'])}
  changed:    #{Time.zone.parse(json['updated_at'])}
  expire:     #{Time.zone.parse(json['valid_to'])}
  outzone:
  delete:
#{contacts_body(json['admin_contacts'], json['tech_contacts'])}
Registrar:
  name:       #{json['registrar']}
  phone:      #{json['registrar_phone']}
  address:    #{json['registrar_address']}
  changed:    #{Time.zone.parse(json['registrar_update_at'])}
#{nameservers_body(json['nameservers'])}
Estonia .ee Top Level Domain WHOIS server
More information at http://internet.ee
    EOS
  end
  # rubocop:enable Metrics/MethodLength

  def contacts_body(admins, techs)
    admins ||= []
    techs  ||= []

    out = ''
    out << (admins.size > 1 ? "\nAdministrative contacts" : "\nAdministrative contact")
    admins.each do |c|
      out << "\n  name:       #{c['name']}"
      out << "\n  email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS"
      out << "\n  registrar:  #{c['registrar']}"
      out << "\n  created:    #{Time.zone.parse(c['created_at'])}"
      out << "\n"
    end

    out << (techs.size > 1 ? "\nTechnical contacts" : "\nTechnical contact:")
    techs.each do |c|
      out << "\n  name:       #{c['name']}"
      out << "\n  email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS"
      out << "\n  registrar:  #{c['registrar']}"
      out << "\n  created:    #{Time.zone.parse(c['created_at'])}"
      out << "\n"
    end
    out
  end

  def nameservers_body(nservers)
    nservers ||= []

    out = "\nName servers:"
    nservers.each do |ns|
      out << "\n  nserver:   #{ns['hostname']}"
      out << "\n  changed:   #{Time.zone.parse(ns['updated_at'])}"
      out << "\n"
    end
    out
  end

  def update_whois_server
    wd = Whois::Record.find_or_initialize_by(name: name)
    wd.body = body
    wd.json = json
    wd.save
  end
end
