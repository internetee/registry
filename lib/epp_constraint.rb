class EppConstraint
  OBJECT_TYPES = {
    domain: { domain: 'https://epp.tld.ee/schema/domain-eis-1.0.xsd' },
    contact: { contact: 'https://epp.tld.ee/schema/contact-ee-1.1.xsd' },
  }.freeze

  def initialize(type)
    @type = type
  end

  # creates parsed_frame, detects epp request object
  def matches?(request)
    # TODO: Maybe move this to controller to keep params clean
    request.params[:raw_frame] = request.params[:raw_frame].gsub!(/(?<=>)(.*?)(?=<)/) { |s| s.strip } if request.params[:raw_frame]
    request.params[:nokogiri_frame] ||= Nokogiri::XML(request.params[:raw_frame] || request.params[:frame])
    request.params[:parsed_frame]   ||= request.params[:nokogiri_frame].dup.remove_namespaces!

    unless %i[keyrelay poll session not_found].include?(@type)
      element = "//#{@type}:#{request.params[:action]}"
      return false if request.params[:nokogiri_frame].xpath(element.to_s, OBJECT_TYPES[@type]).none?
    end

    request.params[:epp_object_type] = @type
    true
  end
end
