# encoding: UTF-8
require 'test_helper'

class EppDomainCheckAuctionTest < EppTestCase
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
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>auction.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}")['avail']
    assert_equal 'Domain is at auction', response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}").text
  end

  def test_idn_ascii_domain_is_unavailable_when_at_auction
    @idn_auction.update!(status: Auction.statuses[:started])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>xn--pramiid-n2a.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}")['avail']
    assert_equal 'Domain is at auction', response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}").text
  end

  def test_idn_unicode_domain_is_unavailable_when_at_auction
    @idn_auction.update!(status: Auction.statuses[:started])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>püramiid.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}")['avail']
    assert_equal 'Domain is at auction', response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}").text
  end

  def test_domain_is_unavailable_when_awaiting_payment
    @auction.update!(status: Auction.statuses[:awaiting_payment])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>auction.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal '0', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}")['avail']
    assert_equal 'Awaiting payment', response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}").text
  end

  def test_domain_is_available_when_payment_received
    @auction.update!(status: Auction.statuses[:payment_received])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <check>
            <domain:check xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}">
              <domain:name>auction.test</domain:name>
            </domain:check>
          </check>
        </command>
      </epp>
    XML

    post epp_check_path, params: { frame: request_xml },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    response_xml = Nokogiri::XML(response.body)
    assert_correct_against_schema response_xml
    assert_epp_response :completed_successfully
    assert_equal '1', response_xml.at_xpath('//domain:name', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}")['avail']
    assert_nil response_xml.at_xpath('//domain:reason', 'domain' => "#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.1')}")
  end
end
