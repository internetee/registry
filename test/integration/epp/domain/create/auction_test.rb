require 'test_helper'

class EppDomainCreateAuctionTest < ApplicationIntegrationTest
  setup do
    @auction = auctions(:one)
    Domain.release_to_auction = true
  end

  teardown do
    Domain.release_to_auction = false
  end

  def test_registers_domain_without_registration_code_when_not_at_auction
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>not-at-auction.test</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_registers_domain_with_correct_registration_code_after_another_auction_when_payment_is_received
    @auction.update!(status: Auction.statuses[:domain_registered], registration_code: 'some')

    another_auction = @auction.dup
    another_auction.uuid = nil
    another_auction.status = Auction.statuses[:payment_received]
    another_auction.registration_code = 'auction002'
    another_auction.save!

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>auction002</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_registers_domain_with_correct_registration_code_when_payment_is_received
    @auction.update!(status: Auction.statuses[:payment_received],
                     registration_code: 'auction001')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>auction001</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end

    @auction.reload
    assert @auction.domain_registered?

    response_xml = Nokogiri::XML(response.body)
    assert_equal '1000', response_xml.at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_domain_cannot_be_registered_without_registration_code
    @auction.update!(status: Auction.statuses[:payment_received],
                     registration_code: 'auction001')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    response_xml = Nokogiri::XML(response.body)
    assert_equal '2003', response_xml.at_css('result')[:code]
    assert_equal 'Required parameter missing; reserved>pw element is required',
                 response_xml.at_css('result msg').text
  end

  def test_domain_cannot_be_registered_with_wrong_registration_code
    @auction.update!(status: Auction.statuses[:payment_received],
                     registration_code: 'auction001')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>wrong</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    response_xml = Nokogiri::XML(response.body)
    assert_equal '2202', response_xml.at_css('result')[:code]
    assert_equal 'Invalid authorization information; invalid reserved>pw value',
                 response_xml.at_css('result msg').text
  end

  def test_domain_cannot_be_registered_when_payment_is_not_received
    @auction.update!(status: Auction.statuses[:awaiting_payment])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
              <domain:registrant>#{contacts(:john).code}</domain:registrant>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
              <eis:reserved>
                <eis:pw>test</eis:pw>
              </eis:reserved>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    response_xml = Nokogiri::XML(response.body)
    assert_equal '2003', response_xml.at_css('result')[:code]
    assert_equal 'Required parameter missing; reserved>pw element required for reserved domains',
                 response_xml.at_css('result msg').text
  end

  def test_domain_cannot_be_registered_when_at_auction
    @auction.update!(status: Auction.statuses[:started])

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>auction.test</domain:name>
            </domain:create>
          </create>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">test</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML

    assert_no_difference 'Domain.count' do
      post '/epp/command/create', { frame: request_xml }, 'HTTP_COOKIE' => 'session=api_bestnames'
    end
    response_xml = Nokogiri::XML(response.body)
    assert_equal '2306', response_xml.at_css('result')[:code]
    assert_equal 'Parameter value policy error: domain is at auction',
                 response_xml.at_css('result msg').text
  end
end
