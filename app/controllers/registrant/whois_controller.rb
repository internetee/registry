class Registrant::WhoisController < RegistrantController
  def index
    authorize! :view, :registrant_whois
  end
end
