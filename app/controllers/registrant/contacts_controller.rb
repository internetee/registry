class Registrant::ContactsController < RegistrantController

  def show
    @contact = contacts.find(params[:id])
    authorize! :read, @contact
  end

  def contacts
    ident_cc, ident = @current_user.registrant_ident.to_s.split '-'
    begin
      BusinessRegistryCache.fetch_by_ident_and_cc(ident, ident_cc).associated_contacts
    rescue Soap::Arireg::NotAvailableError => error
      flash[:notice] = I18n.t(error.json[:message])
      Rails.logger.fatal("[EXCEPTION] #{error.to_s}")
      Contact.none
    end
  end
end