require 'test_helper'

class EppDomainInfoAuctionTest < ApplicationIntegrationTest
  setup do
    @auction = auctions(:one)
    Domain.release_to_auction = true
  end

  teardown do
    Domain.release_to_auction = false
  end

  def test_domain_is_unavailable_when_at_auction
    @auction.update!(status: Auction.statuses[:started])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 'auction.test', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal 'At auction', response_xml.at_xpath('//domain:status', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['s']
  end

  def test_domain_is_reserved_when_awaiting_payment
    @auction.update!(status: Auction.statuses[:awaiting_payment])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 'auction.test', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal 'Awaiting payment', response_xml.at_xpath('//domain:status', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['s']
  end

  def test_domain_is_reserved_when_payment_received
    @auction.update!(status: Auction.statuses[:payment_received])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <info>
            <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
            </domain:info>
          </info>
        </command>
      </epp>
    XML

    post '/epp/command/info', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal 'auction.test', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
    assert_equal 'Reserved', response_xml.at_xpath('//domain:status', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['s']
  end
end
