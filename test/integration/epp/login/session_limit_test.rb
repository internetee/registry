require 'test_helper'

class EppLoginSessionLimitTest < ApplicationIntegrationTest
  setup do
    travel_to Time.zone.parse('2010-07-05')
    EppSession.delete_all
  end

  def test_not_reached
    (EppSession.limit_per_registrar - 1).times do
      EppSession.create!(session_id: SecureRandom.hex,
                         user: users(:api_bestnames),
                         updated_at: Time.zone.parse('2010-07-05'))
    end

    assert_difference 'EppSession.count' do
      post '/epp/session/login', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=new_session_id' }
    end

    assert Nokogiri::XML(response.body).at_css('result[code="1000"]')
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_reached
    EppSession.limit_per_registrar.times do
      EppSession.create!(session_id: SecureRandom.hex,
                         user: users(:api_bestnames),
                         updated_at: Time.zone.parse('2010-07-05'))
    end

    assert_no_difference 'EppSession.count' do
      post '/epp/session/login', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=new_session_id' }
    end

    assert Nokogiri::XML(response.body).at_css('result[code="2501"]')
  end

  private

  def request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <login>
            <clID>test_bestnames</clID>
            <pw>testtest</pw>
            <options>
              <version>1.0</version>
              <lang>en</lang>
            </options>
            <svcs>
              <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
              <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
              <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
              <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
            </svcs>
          </login>
        </command>
      </epp>
    XML
  end
end
