class EppConstraint
  OBJECT_TYPES = {
    domain: { domain: 'urn:ietf:params:xml:ns:domain-1.0' },
    contact: { contact: 'urn:ietf:params:xml:ns:contact-1.0' }
  }

  def initialize(type)
    @type = type
  end

  # creates parsed_frame, detects epp request object
  def matches?(request)
    parsed_frame = Nokogiri::XML(request.params[:raw_frame])

    unless [:keyrelay, :poll].include?(@type)
      element = "//#{@type}:#{request.params[:action]}"
      return false if parsed_frame.xpath("#{element}", OBJECT_TYPES[@type]).none?
    end

    request.params[:parsed_frame] = parsed_frame.remove_namespaces!
    request.params[:epp_object_type] = @type
    true
  end
end
