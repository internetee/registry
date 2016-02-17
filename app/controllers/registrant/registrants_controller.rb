class Registrant::RegistrantsController < RegistrantController

  def show
    @contact = Registrant.find(params[:id])
    @current_user = current_user
    authorize! :read, @contact
    @contact.valid?
  end
end
