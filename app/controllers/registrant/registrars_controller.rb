class Registrant::RegistrarsController < RegistrantController

  def show
    @registrar = Registrar.find(params[:id])
    authorize! :read, @registrar
    @registrar.valid?
  end
end
