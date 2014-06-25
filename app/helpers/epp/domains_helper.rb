module Epp::DomainsHelper
  def create_domain
    domain = Domain.create!(domain_params)
    render '/epp/domains/create'
  end

  def domain_params
    cp = command_params
    {
      name: cp[:name],
      registrar: nil, #well come from current_epp_user
      registered_at: Time.now,
      valid_from: Date.today,
      valid_to: Date.today + cp[:period].to_i.years,
      auth_info: cp[:authInfo]
    }
  end
end
