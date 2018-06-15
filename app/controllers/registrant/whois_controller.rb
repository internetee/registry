# As non-GDPR compliant, this controller is deprecated. Needs to be replaced with one that relies
# on the REST WHOIS API.
class Registrant::WhoisController < RegistrantController
  def index
    authorize! :view, :registrant_whois

    if params[:domain_name].present?
      @domain = WhoisRecord.find_by(name: params[:domain_name]);
    end
  end
end
