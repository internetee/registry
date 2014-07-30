module Epp::DomainsHelper
  def create_domain
    domain = Domain.new(domain_create_params)

    if domain.save
      render '/epp/domains/create'
    else
      if domain.errors.added?(:name, :taken)
        @code = '2302'
        @msg = 'Domain name already exists'
      elsif domain.errors.added?(:name, :epp_domain_reserved)
        @code = '2302'
        @msg = domain.errors[:name].first
      end

      render '/epp/error'
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
      valid_from: Date.today,
      valid_to: Date.today + ph[:period].to_i.years,
      auth_info: ph[:authInfo][:pw]
    }
  end
end
