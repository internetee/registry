module Repp
  module V1
    module Registrar
      class XmlConsoleController < BaseController
        include EppRequestable

        THROTTLED_ACTIONS = %i[load_xml].freeze
        include Shunter::Integration::Throttle

        PREFS = %w[domain-ee contact-ee eis epp-ee].freeze

        SCHEMA_VERSIONS = {
          'epp-ee' => '1.0',
          'eis' => '1.0',
          'contact-ee' => '1.1',
          'default' => '1.2',
        }.freeze

        def load_xml
          cl_trid = "#{current_user.username}-#{Time.zone.now.to_i}"
          obj = validate_path_component(params[:obj])
          epp_action = validate_path_component(params[:epp_action])
          
          xml_path = safe_xml_path(obj, epp_action)
          return render_error(message: 'Invalid request') unless xml_path
          
          xml = File.read(xml_path)
          xml = prepare_payload(xml, cl_trid)

          render_success(data: { xml: xml })
        rescue Errno::ENOENT
          render_error(message: 'Template not found')
        end

        private

        def validate_path_component(component)
          return nil if component.blank?
          sanitized = ActionController::Base.helpers.sanitize(component)
          sanitized if sanitized.match?(/\A[a-zA-Z0-9_-]+\z/)
        end

        def safe_xml_path(obj, epp_action)
          return nil unless obj && epp_action
          
          base_path = Rails.root.join('app/views/epp/sample_requests')
          file_path = base_path.join(obj, "#{epp_action}.xml")
          
          # Проверяем, что путь не вышел за пределы базовой директории
          return file_path if file_path.to_s.start_with?(base_path.to_s)
        end

        def prepare_payload(xml, cl_trid)
          PREFS.map do |pref|
            xml = load_schema_by_prefix(pref, xml)
          end

          xml.gsub!('<clTRID>ABC-12345</clTRID>', "<clTRID>#{cl_trid}</clTRID>")
          xml
        end

        def load_schema_by_prefix(pref, xml)
          version = version_by_prefix(pref)
          xml.gsub!("\"#{pref}\"",
                    "\"#{Xsd::Schema.filename(for_prefix: pref.to_s, for_version: version)}\"")
          xml
        end

        def version_by_prefix(pref)
          key = SCHEMA_VERSIONS.key?(pref) ? pref : 'default'
          SCHEMA_VERSIONS[key]
        end
      end
    end
  end
end
