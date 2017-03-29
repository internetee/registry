module Whois
  class Update
    def update
      # logger.info "Whois record of domain #{domain_name} is regenerated"
    end

    private

      # def generate_json
      #   json_class = "JSON::#{kind.classify}".constantize
      #   json = json_class.new
      #   self[:json] = json.generate
      # end
      #
      # def generate_body
      #   template = Rails.root.join("app/views/whois_record/#{kind}.erb")
      #   body = ERB.new(template.read, nil, '-').result(binding)
      #   self[:body] = body
      # end
  end
end
