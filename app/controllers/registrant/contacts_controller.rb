class Registrant::ContactsController < RegistrantController
  helper_method :domain_ids
  helper_method :domain

  def show
    @contact = Contact.where(id: contacts).find_by(id: params[:id])
    @current_user = current_user

    authorize! :read, @contact
  end

  private

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
      ident_cc, ident = @current_user.registrant_ident.to_s.split '-'
      BusinessRegistryCache.fetch_by_ident_and_cc(ident, ident_cc).associated_domain_ids
    end
  end

  def domain
    Domain.find(params[:domain_id])
  end
end
