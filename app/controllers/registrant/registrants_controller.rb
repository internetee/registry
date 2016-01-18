class Registrant::RegistrantsController < RegistrantController

  def show
    @contact = Registrant.find(params[:id])
    authorize! :read, @contact
    @contact.valid?
  end
end
