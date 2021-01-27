module Actions
  class DomainRenew
    attr_reader :domain
    attr_reader :params
    attr_reader :user

    def initialize(domain, params, user)
      @domain = domain
      @params = params
      @user = user
    end

    def call
      renew
    end

    def renew
      if !domain.renewable? || domain.invalid?
        domain.add_renew_epp_errors
        return
      end

      task = Domains::BulkRenew::SingleDomainRenew.run(domain: domain,
        period: params[:period],
        unit: params[:period_unit],
        registrar: user)

      task.valid?
    end
  end
end
