class Registrant::ContactsController < RegistrantController
  helper_method :domain
  helper_method :fax_enabled?
  skip_authorization_check only: %i[edit update]

  def show
    @contact = current_user_contacts.find(params[:id])
    authorize! :read, @contact
  end

  def edit
    @contact = current_user_contacts.find(params[:id])
  end

  def update
    @contact = current_user_contacts.find(params[:id])
    @contact.attributes = contact_params
    response = update_contact_via_api(@contact.uuid)
    updated = response.is_a?(Net::HTTPSuccess)

    if updated
      redirect_to registrant_domain_contact_url(domain, @contact), notice: t('.updated')
    else
      parsed_response = JSON.parse(response.body, symbolize_names: true)
      @errors = parsed_response[:errors]
      render :edit
    end
  end

  private

  def domain
    current_user_domains.find(params[:domain_id])
  end

  def contact_params
    permitted = %i[
      name
      email
      phone
    ]

    permitted << :fax if fax_enabled?
    permitted += %i[street zip city state country_code] if Contact.address_processing?
    params.require(:contact).permit(*permitted)
  end

  def access_token
    uri = URI.parse("#{ENV['registrant_api_base_url']}/api/v1/registrant/auth/eid")
    request = Net::HTTP::Post.new(uri)
    request.form_data = access_token_request_params

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
      http.request(request)
    end

    json_doc = JSON.parse(response.body, symbolize_names: true)
    json_doc[:access_token]
  end

  def access_token_request_params
    { ident: current_registrant_user.ident,
      first_name: current_registrant_user.first_name,
      last_name: current_registrant_user.last_name }
  end

  def fax_enabled?
    ENV['fax_enabled'] == 'true'
  end

  def contact_update_api_params
    params = contact_params
    params = normalize_address_attributes_for_api(params) if Contact.address_processing?
    params
  end

  def normalize_address_attributes_for_api(params)
    normalized = params
    address_parts = {}

    Contact.address_attribute_names.each do |attr|
      attr = attr.to_sym
      address_parts[attr] = params[attr]
      normalized.delete(attr)
    end

    normalized[:address] = address_parts
    normalized
  end

  def update_contact_via_api(uuid)
    uri = URI.parse("#{ENV['registrant_api_base_url']}/api/v1/registrant/contacts/#{uuid}")
    request = Net::HTTP::Patch.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['Content-type'] = 'application/json'
    request.body = contact_update_api_params.to_json

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
      http.request(request)
    end
  end
end
