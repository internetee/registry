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
      period = params[:period]
      unit = params[:period_unit]

      task = Domains::BulkRenew::SingleDomainRenew.run(domain: domain,
        period: params[:period],
        unit: params[:period_unit],
        registrar: user)

      return true if task

      puts task.errors

      false
    end
  end
end
