class Registrant::WhoisController < RegistrantController
  def index
    authorize! :view, Registrant::Whois
    if params[:domain_name].present?
      whois_url = "#{ENV['restful_whois_url']}/v1/#{params[:domain_name]}"
      binding.pry
      page = Nokogiri::HTML(open(whois_url))
      @results = 'ee'
    end
  end
end
