require 'test_helper'

class EppDomainRenewTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = false

  def setup
    travel_to Time.zone.parse('2010-07-05')
  end

  def test_domain_cannot_be_renewed_when_invalid
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <renew>
            <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>invalid.test</domain:name>
              <domain:curExpDate>2010-07-05</domain:curExpDate>
              <domain:period unit="m">1</domain:period>
            </domain:renew>
          </renew>
        </command>
      </epp>
    XML

    assert_no_changes -> { domains(:invalid).valid_to } do
      post '/epp/command/renew', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    assert_equal '2304', Nokogiri::XML(response.body).at_css('result')[:code],
                 Nokogiri::XML(response.body).css('result').text
  end
end
