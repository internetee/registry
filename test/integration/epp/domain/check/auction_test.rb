# encoding: UTF-8
require 'test_helper'

class EppDomainCheckAuctionTest < ApplicationIntegrationTest
  setup do
    @auction = auctions(:one)
    @idn_auction = auctions(:idn)
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
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'Domain is at auction', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_idn_ascii_domain_is_unavailable_when_at_auction
    @idn_auction.update!(status: Auction.statuses[:started])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>xn--pramiid-n2a.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'Domain is at auction', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_idn_unicode_domain_is_unavailable_when_at_auction
    @idn_auction.update!(status: Auction.statuses[:started])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>püramiid.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'Domain is at auction', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_domain_is_unavailable_when_awaiting_payment
    @auction.update!(status: Auction.statuses[:awaiting_payment])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_equal 'Awaiting payment', response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_domain_is_available_when_payment_received
    @auction.update!(status: Auction.statuses[:payment_received])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <check>
            <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post '/epp/command/check', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, response_xml.css('result').size
    assert_equal '1', response_xml.at_xpath('//domain:name', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')['avail']
    assert_nil response_xml.at_xpath('//domain:reason', 'domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd')
  end
end
