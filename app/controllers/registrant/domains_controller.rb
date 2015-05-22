class Registrant::DomainsController < RegistrantController
  def index
    authorize! :view, :registrant_domains
  end
end
