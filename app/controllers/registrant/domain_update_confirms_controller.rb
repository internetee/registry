class Registrant::DomainUpdateConfirmsController < RegistrantController
  skip_before_action :authenticate_user!, only: [:show, :create]
  skip_authorization_check only: [:show, :create]

  def show
    @domain = Domain.find(params[:id])
    @domain = nil unless @domain.registrant_update_confirmable?(params[:token])
  end

  def create
  end
end
