class Registrant::DomainUpdateConfirmsController < RegistrantController
  skip_before_action :authenticate_user!, only: [:show, :create]
  skip_authorization_check only: [:show, :create]

  def show
    @domain = Domain.find(params[:id])
    
    # if @domain.present? && params[:token].present? && @domain.registrant_verification_token == params[:token]
    # else 
      # @domain = nil
    # end
  end

  def create
  end
end
