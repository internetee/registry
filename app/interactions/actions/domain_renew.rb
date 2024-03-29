module Actions
  class DomainRenew
    attr_reader :domain, :params, :user

    def initialize(domain, params, user)
      @domain = domain
      @params = params
      @user = user
    end

    def call
      domain.is_renewal = true
      if !domain.renewable? || domain.invalid?
        domain.add_renew_epp_errors
        false
      else
        domain.validate_exp_dates(params[:exp_date])
        renew
      end
    end

    def renew
      return false if domain.errors[:epp_errors].any?

      task = Domains::BulkRenew::SingleDomainRenew.run(domain: domain,
                                                       period: params[:period],
                                                       unit: params[:period_unit],
                                                       registrar: user)
      task.valid?
    end
  end
end
