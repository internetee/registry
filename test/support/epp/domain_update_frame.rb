# frozen_string_literal: true

module Epp
  module DomainUpdateFrame
    EPP_EE_NS = -> { Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0') }
    DOMAIN_EE_NS = -> { Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2') }
    EIS_NS = -> { Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0') }
    LEGAL_DOCUMENT_BODY = ('test' * 2000).freeze

    def epp_domain_update_xml(domain_name:, chg: nil, add: nil, rem: nil, extension: nil)
      chg_xml = chg ? "<domain:chg>#{chg}</domain:chg>" : ''
      add_xml = add ? "<domain:add>#{add}</domain:add>" : ''
      rem_xml = rem ? "<domain:rem>#{rem}</domain:rem>" : ''
      ext_xml = extension ? "<extension>#{extension}</extension>" : ''

      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <epp xmlns="#{EPP_EE_NS.call}">
          <command>
            <update>
              <domain:update xmlns:domain="#{DOMAIN_EE_NS.call}">
                <domain:name>#{domain_name}</domain:name>
                #{chg_xml}
                #{add_xml}
                #{rem_xml}
              </domain:update>
            </update>
            #{ext_xml}
          </command>
        </epp>
      XML
    end

    def domain_chg_body(registrant: nil, auth_pw: nil, registrant_verified: nil)
      parts = []
      if registrant
        parts << domain_chg_registrant(registrant, verified: registrant_verified)
      end
      parts << domain_chg_auth_info(auth_pw) if auth_pw
      parts.join
    end

    def domain_chg_registrant(code, verified: nil)
      attrs = verified ? %( verified="#{verified}") : ''
      "<domain:registrant#{attrs}>#{code}</domain:registrant>"
    end

    def domain_chg_auth_info(pw)
      "<domain:authInfo><domain:pw>#{pw}</domain:pw></domain:authInfo>"
    end

    def eis_extdata_extension(legal_document: false, reserved_pw: nil)
      parts = []
      parts << %(<eis:legalDocument type="pdf">#{LEGAL_DOCUMENT_BODY}</eis:legalDocument>) if legal_document
      if reserved_pw
        parts << <<~PW.strip
          <eis:reserved>
            <eis:pw>#{reserved_pw}</eis:pw>
          </eis:reserved>
        PW
      end
      return nil if parts.empty?

      <<~EXT
        <eis:extdata xmlns:eis="#{EIS_NS.call}">
          #{parts.join("\n          ")}
        </eis:extdata>
      EXT
    end

    def post_epp_domain_update(frame, session: 'api_bestnames')
      post epp_update_path, params: { frame: frame },
           headers: { 'HTTP_COOKIE' => "session=#{session}" }
      @response_xml = nil
    end

    def response_xml
      @response_xml ||= Nokogiri::XML(response.body)
    end

    def assert_epp_domain_update(response_type)
      assert_correct_against_schema response_xml
      assert_epp_response response_type
    end

    def activate_dispute_on_domain(domain)
      dispute = disputes(:expired)
      dispute.update!(starts_at: Time.zone.now, expires_at: Time.zone.now + 5.days, closed: nil)
      domain.reload
      dispute
    end
  end
end
