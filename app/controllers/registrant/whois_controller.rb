class Registrant::WhoisController < RegistrantController
  def index
    authorize! :view, :registrant_whois

    if params[:domain_name].present?
      @domain = Whois::Record.find_by(domain_name: params[:domain_name])
    end
  end
end
