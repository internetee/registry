class Registrar
  class XmlConsolesController < DeppController
    authorize_resource class: false

    def show
    end

    def create
      begin
        @result = depp_current_user.server.request(params[:payload])
		    checking_schema_valid_path(params[:payload])
      rescue
        @result = 'CONNECTION ERROR - Is the EPP server running?'
      end
      render :show
    end

    def load_xml
      cl_trid = "#{depp_current_user.tag}-#{Time.zone.now.to_i}"
      xml_dir_path = Rails.root + 'app/views/registrar/xml_consoles/epp_requests'
      xml = File.read("#{xml_dir_path}/#{params[:obj]}/#{params[:epp_action]}.xml")
      xml.gsub!('<clTRID>ABC-12345</clTRID>', "<clTRID>#{cl_trid}</clTRID>")
      render plain: xml
    end

	private

		def checking_schema_valid_path(payload)
      path = regex_to_find_domain_schema(payload)

      @result = template_wrong_path unless array_valid_paths.include? path
		end

		def array_valid_paths
			Xsd::Schema::PREFIXES.map{|prefix| Xsd::Schema.filename(for_prefix: prefix)}
		end

		def template_wrong_path
      'Wrong schema path'
    end

    def regex_to_find_domain_schema(payload)
      domain_schema_tag = payload.scan(/xmlns:domain[\S]+/)
      schema_path = domain_schema_tag.to_s.match(/https?:\/\/[\S]+/)[0]
      path = schema_path.split('\\')[0]
      path
    end
  end
end
