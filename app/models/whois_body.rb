class WhoisBody < ActiveRecord::Base
  belongs_to :domain

  def update_whois_server
    return logger.info "NO WHOIS NAME for whois_body id: #{id}" if name.blank?
    wd = Whois::Domain.find_or_initialize_by(name: name)
    wd.whois_body = whois_body
    wd.whois_json = whois_json
    wd.save
  end

  # rubocop:disable Metrics/MethodLength
  def h
    @h ||= HashWithIndifferentAccess.new
  end

  def update
    h[:name] = domain.name
    h[:registrant] = domain.registrant.name
    h[:status] = domain.domain_statuses.map(&:human_value).join(', ')
    h[:registered] = domain.registered_at and domain.registered_at.to_s(:db)
    h[:updated_at] = domain.updated_at and domain.updated_at.to_s(:db)
    h[:valid_to] = domain.valid_to and domain.valid_to.to_s(:db)
    
    h[:registrar] = domain.registrar.name
    h[:registrar_phone] = domain.registrar.phone
    h[:registrar_address] = domain.registrar.address
    h[:registrar_update_at] = domain.registrar.updated_at.to_s(:db)
    h[:admin_contacts] = []
    domain.admin_contacts.each do |ac|
      h[:admin_contacts] << {
        name: ac.name,
        email: ac.email,
        registrar: ac.registrar.name,
        created_at: ac.created_at.to_s(:db)
      }
    end
    h[:tech_contacts] = []
    domain.tech_contacts.each do |tc|
      h[:tech_contacts] << {
        name: tc.name,
        email: tc.email,
        registrar: tc.registrar.name,
        created_at: tc.created_at.to_s(:db)
      }
    end
    h[:nameservers] = []
    domain.nameservers.each do |ns|
      h[:nameservers] << {
        hostname: ns.hostname,
        updated_at: ns.updated_at.to_s(:db)
      }
    end

    self.name = h[:name]
    self.whois_body = body
    self.whois_json = h
    save
  end

  def body
    <<-EOS
Estonia .ee Top Level Domain WHOIS server

Domain:
  name:       #{h[:name]}
  registrant: #{h[:registrant]}
  status:     #{h[:status]}
  registered: #{h[:registered]}
  changed:    #{h[:updated_at]}
  expire:     #{h[:valid_to]}
  outzone:
  delete:
#{contacts_body(h[:admin_contacts], h[:tech_contacts])}
Registrar:
  name:       #{h[:registrar]}
  phone:      #{h[:registrar_phone]}
  address:    #{h[:registrar_address]}
  changed:    #{h[:registrar_update_at]}
#{nameservers_body(h[:nameservers])}
Estonia .ee Top Level Domain WHOIS server
More information at http://internet.ee
    EOS
  end
  # rubocop:enable Metrics/MethodLength

  def contacts_body(admins, techs)
    out = ''
    out << (admins.size > 1 ? "\nAdministrative contacts" : "\nAdministrative contact")
    admins.each do |c|
      out << "\n  name:       #{c[:name]}"
      out << "\n  e-mail:     Not Disclosed - Visit www.internet.ee for webbased WHOIS"
      out << "\n  registrar:  #{c[:registrar]}"
      out << "\n  created:    #{c[:created_at]}"
      out << "\n"
    end

    out << (techs.size > 1 ? "\nTechnical contacts" : "\nTechnical contact:")
    techs.each do |c|
      out << "\n  name:       #{c[:name]}"
      out << "\n  e-mail:     Not Disclosed - Visit www.internet.ee for webbased WHOIS"
      out << "\n  registrar:  #{c[:registrar]}"
      out << "\n  created:    #{c[:created_at]}"
      out << "\n"
    end
    out
  end

  def nameservers_body(nservers)
    out = "\nName servers:"
    nservers.each do |ns|
      out << "\n  nserver:   #{ns[:hostname]}"
      out << "\n  changed:   #{ns[:updated_at]}"
      out << "\n"
    end
    out
  end
end
