module Epp::DomainsHelper
  def create_domain
    domain = Domain.create!(domain_params)
    render '/epp/domains/create'
  end

  def domain_params
    cp = command_params
    {
      name: cp[:name],
      registrar_id: current_epp_user.registrar.try(:id),
      registered_at: Time.now,
      valid_from: Date.today,
      valid_to: Date.today + cp[:period].to_i.years,
      auth_info: cp[:authInfo]
    }
  end
end
