class Registrar
  class XmlConsolesController < DeppController
    PREFS = %w[
      domain-ee
      contact-ee
      eis
      epp-ee
    ].freeze

    authorize_resource class: false

    def show; end

    def create
      begin
        @result = depp_current_user.server.request(params[:payload])

        check_schema_path(params[:payload])
      rescue StandardError
        @result = 'CONNECTION ERROR - Is the EPP server running?'
      end
      render :show
    end

    def load_xml
      cl_trid = "#{depp_current_user.tag}-#{Time.zone.now.to_i}"
      xml_dir_path = Rails.root + 'app/views/registrar/xml_consoles/epp_requests'
      xml = File.read("#{xml_dir_path}/#{params[:obj]}/#{params[:epp_action]}.xml")
      xml = prepare_payload(xml, cl_trid)

      render plain: xml
    end

    protected

    def check_schema_path(payload)
      path = nil
      path = regex_to_find_domain_schema(payload) if regex_to_find_domain_schema(payload).present?
      path = regex_to_find_contact_schema(payload) if regex_to_find_contact_schema(payload).present?
      path = regex_to_find_poll_schema(payload) if regex_to_find_poll_schema(payload).present?

      @result = wrong_path_response unless array_valid_paths.include? path
    end

    def array_valid_paths
      Xsd::Schema::PREFIXES.map { |prefix| Xsd::Schema.filename(for_prefix: prefix) }
    end

    def wrong_path_response
      cl_trid = "#{depp_current_user.tag}-#{Time.zone.now.to_i}"

      <<~XML
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
          <epp xmlns=\"https://epp.tld.ee/schema/epp-ee-1.0.xsd\"
              xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
              xsi:schemaLocation=\"lib/schemas/epp-ee-1.0.xsd\">
            <response>
              <result code=\"2100\">
                <msg lang=\"en\">Wrong schema</msg>
              </result>
              <trID>
                <clTRID>#{cl_trid}</clTRID>
                <svTRID>eePrx-#{Time.zone.now.to_i}</svTRID>
              </trID>
            </response>
          </epp>
      XML
    end

    def regex_to_find_domain_schema(payload)
      domain_schema_tag = payload.scan(/xmlns:domain\S+/)
      return if domain_schema_tag.empty?

      schema_path = domain_schema_tag.to_s.match(%r{https?://\S+})[0]
      schema_path.split('\\')[0]
    end

    def regex_to_find_contact_schema(payload)
      contact_schema_tag = payload.scan(/xmlns:contact\S+/)
      return if contact_schema_tag.empty?

      schema_path = contact_schema_tag.to_s.match(%r{https?://\S+})[0]
      schema_path.split('\\')[0]
    end

    def regex_to_find_poll_schema(payload)
      contact_schema_tag = payload.scan(/poll\S+/)
      return if contact_schema_tag.empty?

      'https://epp.tld.ee/schema/epp-ee-1.0.xsd'
    end

    def prepare_payload(xml, cl_trid)
      PREFS.map do |pref|
        xml.gsub!('"' + pref.to_s + '"',
                  "\"#{Xsd::Schema.filename(for_prefix: pref.to_s)}\"")
      end

      xml.gsub!('<clTRID>ABC-12345</clTRID>', "<clTRID>#{cl_trid}</clTRID>")
      xml
    end
  end
end
