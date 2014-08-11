module Epp::DomainsHelper
  def create_domain
    ph = params_hash['epp']['command']['create']['create']

    unless xml_attrs_present?(ph, [['name'], ['ns'], ['authInfo'], ['contact'], ['registrant']])
      render '/epp/error' and return
    end

    @domain = Domain.new(domain_create_params(ph))

    if owner_contact_id = Contact.find_by(code: ph[:registrant]).try(:id)
      @domain.owner_contact_id = owner_contact_id
    else
      epp_errors << {code: '2303', msg: I18n.t('errors.messages.epp_registrant_not_found'), value: {obj: 'registrant', val: ph[:registrant]}}
      render '/epp/error' and return
    end

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
    # TODO support period unit
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.renew(@ph[:curExpDate], @ph[:period])

    render '/epp/domains/renew'
  end

  ### HELPER METHODS ###
  private

  def validate_domain_renew_request
    @ph = params_hash['epp']['command']['renew']['renew']
    xml_attrs_present?(@ph, [['name'], ['curExpDate'], ['period']])
  end

  def find_domain
    domain = Domain.find_by(name: @ph[:name])
    unless domain
      epp_errors << {code: '2303', msg: I18n.t('errors.messages.epp_domain_not_found'), value: {obj: 'name', val: @ph[:name]}}
    end
    domain
  end

  def domain_create_params(ph)
    {
      name: ph[:name],
      registrar_id: current_epp_user.registrar.try(:id),
      registered_at: Time.now,
      period: ph[:period].to_i,
      valid_from: Date.today,
      valid_to: Date.today + ph[:period].to_i.years,
      auth_info: ph[:authInfo][:pw]
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
