class Registrant::ContactsController < RegistrantController

  def show
    @contact   = Contact.where(id: contacts).find_by(id: params[:id])
    @current_user = current_user
    authorize! :read, @contact
  end

  def contacts
    ident_cc, ident = @current_user.registrant_ident.to_s.split '-'
    begin
      DomainContact.where(domain_id: BusinessRegistryCache.fetch_by_ident_and_cc(ident, ident_cc).associated_domain_ids).pluck(:contact_id)
    rescue Soap::Arireg::NotAvailableError => error
      flash[:notice] = I18n.t(error.json[:message])
      Rails.logger.fatal("[EXCEPTION] #{error.to_s}")
      []
    end
  end
end