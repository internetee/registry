module Epp::DomainsHelper
  def create_domain
    @domain = Domain.new(domain_create_params)

    Domain.transaction do
      if @domain.save && @domain.attach_contacts(domain_contacts) && @domain.attach_nameservers(domain_nameservers)
        render '/epp/domains/create'
      else
        handle_errors
        render '/epp/error'
        raise ActiveRecord::Rollback
      end
    end
  end

  def check_domain
    ph = params_hash['epp']['command']['check']['check']
    @domains = Domain.check_availability(ph[:name])
    render '/epp/domains/check'
  end

  ### HELPER METHODS ###
  private

  def domain_create_params
    ph = params_hash['epp']['command']['create']['create']
    {
      name: ph[:name],
      registrar_id: current_epp_user.registrar.try(:id),
      registered_at: Time.now,
      period: ph[:period].to_i,
      valid_from: Date.today,
      valid_to: Date.today + ph[:period].to_i.years,
      auth_info: ph[:authInfo][:pw],
      owner_contact_id: Contact.find_by(code: ph[:registrant]).try(:id)
    }
  end

  def domain_contacts
    parsed_frame = Nokogiri::XML(params[:frame]).remove_namespaces!

    res = {}
    Contact::CONTACT_TYPES.each do |ct|
      res[ct.to_sym] ||= []
      parsed_frame.css("contact[type='#{ct}']").each do |x|
        res[ct.to_sym] << Hash.from_xml(x.to_s).with_indifferent_access
      end
    end

    res
  end

  def domain_nameservers
    ph = params_hash['epp']['command']['create']['create']['ns']
    return [] unless ph
    return ph[:hostObj] if ph[:hostObj]
    return ph[:hostAttr] if ph[:hostAttr]
    []
  end

  def handle_errors
    handle_epp_errors({
      '2302' => ['Domain name already exists', 'Domain name is reserved or restricted'],
      '2306' => ['Registrant is missing', 'Nameservers count must be between 1-13', 'Admin contact is missing'],
      '2303' => ['Contact was not found'],
      '2005' => ['Hostname is invalid', 'IP is invalid']
    }, @domain)
  end
end
