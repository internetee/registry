class Registrant::WhoisController < RegistrantController
  def index
    authorize! :view, :registrant_whois

    if params[:domain_name].present?
      @domain = WhoisRecord.find_by(name: params[:domain_name]);
    end
  end
end
