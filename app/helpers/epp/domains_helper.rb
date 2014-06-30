module Epp::DomainsHelper
  def create_domain
    domain = Domain.create!(domain_create_params)
    render '/epp/domains/create'
  end

  def check_domain
    @domains = Domain.check_availability(domain_check_params[:names])
    render '/epp/domains/check'
  end

  ### HELPER METHODS ###

  def domain_create_params
    node_set = parsed_frame.css("epp command create create").children.select(&:element?)
    command_params = node_set.inject({}) {|hash, obj| hash[obj.name.to_sym] = obj.text;hash }

    {
      name: command_params[:name],
      registrar_id: current_epp_user.registrar.try(:id),
      registered_at: Time.now,
      valid_from: Date.today,
      valid_to: Date.today + command_params[:period].to_i.years,
      auth_info: command_params[:authInfo]
    }
  end

  def domain_check_params
    node_set = parsed_frame.css('epp command check check name')
    node_set.inject({names: []}){ |hash, obj| hash[:names] << obj.text; hash }
  end
end
