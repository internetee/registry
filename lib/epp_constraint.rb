class EppConstraint
  OBJECT_TYPES = {
    domain: { domain: 'https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd' },
    contact: { contact: 'https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd' }
  }

  def initialize(type)
    @type = type
  end

  # creates parsed_frame, detects epp request object
  def matches?(request)
    parsed_frame = Nokogiri::XML(request.params[:raw_frame])

    unless [:keyrelay, :poll, :session].include?(@type)
      element = "//#{@type}:#{request.params[:action]}"
      return false if parsed_frame.xpath("#{element}", OBJECT_TYPES[@type]).none?
      # TODO: Support multiple schemas
      request.params[:schema] = OBJECT_TYPES[@type][@type].split('/').last
    end

    request.params[:parsed_frame] = parsed_frame.remove_namespaces!
    request.params[:epp_object_type] = @type
    true
  end
end
