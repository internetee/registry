class EppConstraint
  OBJECT_TYPES = {
    domain: [
      { domain: Xsd::Schema.filename(for_prefix: 'domain-ee') },
      { domain: Xsd::Schema.filename(for_prefix: 'domain-eis') }
    ],
    contact: { contact: Xsd::Schema.filename(for_prefix: 'contact-ee') }
  }.freeze

  def initialize(type)
    @type = type
  end

  # creates parsed_frame, detects epp request object
  def matches?(request)
    # TODO: Maybe move this to controller to keep params clean
    return redirect_to_error_controller(request) if request.params[:action] == 'wrong_schema'

    if request.params[:raw_frame]
      request.params[:raw_frame] = request.params[:raw_frame].gsub!(/(?<=>)(.*?)(?=<)/) do |s|
        s.strip
      end
    end
    request.params[:nokogiri_frame] ||= Nokogiri::XML(request.params[:raw_frame] || request.params[:frame])
    request.params[:parsed_frame]   ||= request.params[:nokogiri_frame].dup.remove_namespaces!

    unless %i[poll session].include?(@type)
      element = "//#{@type}:#{request.params[:action]}"

      if @type == :domain
        OBJECT_TYPES[@type].each do |obj|
          return true unless request.params[:nokogiri_frame].xpath(element.to_s, obj).none?
        end
        return false
      end

      return false if request.params[:nokogiri_frame].xpath(element.to_s, OBJECT_TYPES[@type]).none?
    end

    request.params[:epp_object_type] = @type
    true
  end

  def redirect_to_error_controller(request)
    request.params[:epp_object_type] = @error
    true
  end
end
