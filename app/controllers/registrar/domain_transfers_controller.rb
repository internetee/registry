class Registrar
  class DomainTransfersController < DeppController
    before_action do
      authorize! :transfer, Depp::Domain
    end

    def new
    end

    def create
      domain = Depp::Domain.new(current_user: depp_current_user)
      @data = domain.transfer(params)
    end
  end
end
