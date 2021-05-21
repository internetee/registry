class EppConstraint
  OBJECT_TYPES = {
    domain: { domain: Xsd::Schema.filename(for_prefix: 'domain-eis') },
    contact: { contact: Xsd::Schema.filename(for_prefix: 'contact-ee') },
  }.freeze

  def initialize(type)
    @type = type
  end

  # creates parsed_frame, detects epp request object
  def matches?(request)
    # TODO: Maybe move this to controller to keep params clean
    request.params[:raw_frame] = request.params[:raw_frame].gsub!(/(?<=>)(.*?)(?=<)/) { |s| s.strip} if request.params[:raw_frame]
    request.params[:nokogiri_frame] ||= Nokogiri::XML(request.params[:raw_frame] || request.params[:frame])
    request.params[:parsed_frame]   ||= request.params[:nokogiri_frame].dup.remove_namespaces!

    unless %i[poll session].include?(@type)
      element = "//#{@type}:#{request.params[:action]}"
      return false if request.params[:nokogiri_frame].xpath("#{element}", OBJECT_TYPES[@type]).none?
    end

    request.params[:epp_object_type] = @type
    true
  end
end
