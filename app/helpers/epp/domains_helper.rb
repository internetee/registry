module Epp::DomainsHelper
  def create_domain
    @domain = Domain.new(domain_create_params)

    Domain.transaction do
      if @domain.save && @domain.attach_contacts(domain_contacts) && @domain.attach_nameservers(domain_nameservers)
        render '/epp/domains/create'
      else
        handle_errors(@domain)
        raise ActiveRecord::Rollback
      end
    end
  end

  def check_domain
    ph = params_hash['epp']['command']['check']['check']
    @domains = Domain.check_availability(ph[:name])
    render '/epp/domains/check'
  end

  def renew_domain
    ph = params_hash['epp']['command']['renew']['renew']

    @domain = Domain.find_by(name: ph[:name])
    unless @domain
      epp_errors << {code: '2303', msg: I18n.t('errors.messages.epp_domain_not_found'), value: {obj: 'domain', val: ph[:name]}}
      render '/epp/error' and return
    end

    if @domain.renew(ph[:curExpDate], ph[:period])
      render '/epp/domains/renew'
    else
      handle_errors
      render '/epp/error'
    end
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
end
