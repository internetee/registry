require 'test_helper'

class EppPollTest < ApplicationIntegrationTest
  def test_messages
    post '/epp/command/poll', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_equal '1301', Nokogiri::XML(response.body).at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('msgQ').size
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_no_messages
    registrars(:bestnames).messages.delete_all(:delete_all)
    post '/epp/command/poll', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    assert_equal '1300', Nokogiri::XML(response.body).at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  private

  def request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <poll op="req"/>
        </command>
      </epp>
    XML
  end
end
