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
          obj = ActionController::Base.helpers.sanitize(params[:obj])
          epp_action = ActionController::Base.helpers.sanitize(params[:epp_action])
          xml_dir_path = Rails.root.join('app/views/epp/sample_requests').to_s
          xml = File.read("#{xml_dir_path}/#{obj}/#{epp_action}.xml")
          xml = prepare_payload(xml, cl_trid)

          render_success(data: { xml: xml })
        end

        private

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
