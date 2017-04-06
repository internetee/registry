class Registrar
  class DashboardController < BaseController
    authorize_resource class: false

    def show
      if can?(:show, :poll)
        redirect_to registrar_poll_url and return
      elsif can?(:show, Invoice)
        redirect_to registrar_invoices_url and return
      end
    end
  end
end
