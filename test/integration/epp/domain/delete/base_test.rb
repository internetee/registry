require 'test_helper'

class EppDomainDeleteBaseTest < ActionDispatch::IntegrationTest
  def setup
    @domain = domains(:shop)
  end

  def test_bypasses_domain_and_registrant_and_contacts_validation
    assert_equal 'invalid.test', domains(:invalid).name

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>invalid.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    assert_includes Domain.find_by(name: 'invalid.test').statuses, DomainStatus::PENDING_DELETE_CONFIRMATION
    assert_equal '1001', Nokogiri::XML(response.body).at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_discarded_domain_cannot_be_deleted
    assert_equal 'shop.test', @domain.name
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <delete>
            <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
            </domain:delete>
          </delete>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/delete', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    assert_equal '2105', Nokogiri::XML(response.body).at_css('result')[:code]
  end
end