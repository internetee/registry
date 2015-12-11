class Registrant::DomainsController < RegistrantController
  def index
    authorize! :view, :registrant_domains
    ident_cc, ident = @current_user.registrant_ident.split '-'
    @domains = BusinessRegistryCache.fetch_associated_domains ident, ident_cc
  end
end
