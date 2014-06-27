module Epp::DomainsHelper
  def create_domain
    domain = Domain.create!(domain_params)
    render '/epp/domains/create'
  end

  def check_domain
    cp = command_params_for('check')
    @domain = cp[:name]

    render '/epp/domains/check'
  end

  ### HELPER METHODS ###

  def domain_params
    cp = command_params_for('create')
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
