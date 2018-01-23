class Registrar
  class DomainTransfersController < DeppController
    before_action do
      authorize! :transfer, Depp::Domain
    end

    def new
    end

    def create
      params[:request] = true # EPP domain:transfer "op" attribute
      domain = Depp::Domain.new(current_user: depp_current_user)
      @data = domain.transfer(params)
      render :new unless response_ok?
    end
  end
end
