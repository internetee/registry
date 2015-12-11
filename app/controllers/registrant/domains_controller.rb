class Registrant::DomainsController < RegistrantController
  def index
    authorize! :view, :registrant_domains
    ident_cc, ident = @current_user.registrant_ident.split '-'
    begin
      @domains = BusinessRegistryCache.fetch_associated_domains ident, ident_cc
    rescue Soap::Arireg::NotAvailableError => error
      flash[:notice] = I18n.t(error.message[:message])
      @domains = []
    end
  end
end
