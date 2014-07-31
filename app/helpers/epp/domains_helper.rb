module Epp::DomainsHelper
  def create_domain
    @domain = Domain.new(domain_create_params)

    Domain.transaction do
      if @domain.save && @domain.attach_contacts(domain_contacts)
        render '/epp/domains/create'
      else
        handle_domain_name_errors
        render '/epp/error'
      end
    end
  end

  def check_domain
    ph = params_hash['epp']['command']['check']['check']
    @domains = Domain.check_availability(ph[:name])
    render '/epp/domains/check'
  end

  ### HELPER METHODS ###

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

  def handle_domain_name_errors
    [:epp_domain_taken, :epp_domain_reserved].each do |x|
      if @domain.errors.added?(:name, x)
        epp_errors << {code: '2302', msg: @domain.errors[:name].first}
      end
    end
  end

end
