class Registrant::WhoisController < RegistrantController
  def index
    authorize! :view, Registrant::Whois
  end
end
