class Registrar
  class BulkRenewController < DeppController
    def index; end

    def new
      authorize! :manage, :repp
    end
  end
end
