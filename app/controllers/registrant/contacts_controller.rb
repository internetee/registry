class Registrant::ContactsController < RegistrantController

  def show
    @contact = Contact.find(params[:id])
    authorize! :read, @contact
    @contact.valid?
  end
end