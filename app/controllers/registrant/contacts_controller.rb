class Registrant::ContactsController < RegistrantController
  helper_method :domain_ids
  def show
    @contact      = Contact.where(id: contacts).find_by(id: params[:id])

    authorize! :read, @contact
  end

  def contacts
    begin
      DomainContact.where(domain_id: domain_ids).pluck(:contact_id) | Domain.where(id: domain_ids).pluck(:registrant_id)
    rescue Soap::Arireg::NotAvailableError => error
      flash[:notice] = I18n.t(error.json[:message])
      Rails.logger.fatal("[EXCEPTION] #{error.to_s}")
      []
    end
  end

  def domain_ids
    @domain_ids ||= begin
      ident_cc, ident = current_registrant_user.registrant_ident.to_s.split '-'
      BusinessRegistryCache.fetch_by_ident_and_cc(ident, ident_cc).associated_domain_ids
    end
  end
end