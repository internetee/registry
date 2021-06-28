class EppConstraint
  OBJECT_TYPES = {
    domain: [
      { domain: Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1') },
      { domain: Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2') },
      { domain: Xsd::Schema.filename(for_prefix: 'domain-eis', for_version: '1.0') },
    ],
    contact: { contact: Xsd::Schema.filename(for_prefix: 'contact-ee', for_version: '1.1') },
  }.freeze

  def initialize(type)
    @type = type
  end

  # creates parsed_frame, detects epp request object
  def matches?(request)
    # TODO: Maybe move this to controller to keep params clean
    return redirect_to_error_controller(request) if request.params[:action] == 'wrong_schema'

    request = parse_raw_frame(request) if request.params[:raw_frame]

    request = parse_params(request)

    unless %i[poll session].include?(@type)
      element = "//#{@type}:#{request.params[:action]}"

      return enumerate_domain_object(request, element) if @type == :domain

      return false if request.params[:nokogiri_frame].xpath(element.to_s, OBJECT_TYPES[@type]).none?
    end

    request.params[:epp_object_type] = @type
    true
  end

  def parse_raw_frame(request)
    request.params[:raw_frame] = request.params[:raw_frame].gsub!(/(?<=>)(.*?)(?=<)/, &:strip)
    request
  end

  def enumerate_domain_object(request, element)
    OBJECT_TYPES[@type].each do |obj|
      return true unless request.params[:nokogiri_frame].xpath(element.to_s, obj).none?
    end
    false
  end

  def parse_params(request)
    request.params[:nokogiri_frame] ||= Nokogiri::XML(request.params[:raw_frame] || request.params[:frame])
    request.params[:parsed_frame] ||= request.params[:nokogiri_frame].dup.remove_namespaces!

    request
  end

  def redirect_to_error_controller(request)
    request.params[:epp_object_type] = @error
    true
  end
end
