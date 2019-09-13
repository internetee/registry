# encoding: UTF-8
require 'test_helper'

class EppDomainCreateAuctionIdnTest < EppTestCase
  def setup
    super

    @idn_auction = auctions(:idn)
    Domain.release_to_auction = true
  end

  def teardown
    super

    Domain.release_to_auction = false
  end

  def test_domain_with_ascii_idn_cannot_be_registered_without_registration_code
    @idn_auction.update!(status: Auction.statuses[:payment_received],
                        registration_code: "auction001")

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>xn--pramiid-n2a.test</domain:name>
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

    refute Domain.where(name: @idn_auction.domain).exists?

    @idn_auction.reload
    refute @idn_auction.domain_registered?
    assert_epp_response :required_parameter_missing
  end

  def test_domain_with_unicode_idn_cannot_be_registered_without_registration_code
    @idn_auction.update!(status: Auction.statuses[:payment_received],
                        registration_code: "auction001")

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>püramiid.test</domain:name>
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

    refute Domain.where(name: @idn_auction.domain).exists?

    @idn_auction.reload
    refute @idn_auction.domain_registered?
    assert_epp_response :required_parameter_missing
  end

  def test_domain_with_ascii_idn_cannot_be_registered_without_winning_the_auction
    @idn_auction.started!

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>xn--pramiid-n2a.test</domain:name>
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

    refute Domain.where(name: @idn_auction.domain).exists?

    @idn_auction.reload
    refute @idn_auction.domain_registered?
    assert_epp_response :parameter_value_policy_error
  end

  def test_domain_with_unicode_idn_cannot_be_registered_without_winning_the_auction
    @idn_auction.started!

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>püramiid.test</domain:name>
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

    refute Domain.where(name: @idn_auction.domain).exists?

    @idn_auction.reload
    refute @idn_auction.domain_registered?
    assert_epp_response :parameter_value_policy_error
  end

  def test_registers_unicode_domain_with_correct_registration_code_when_payment_is_received
    @idn_auction.update!(status: Auction.statuses[:payment_received],
                     registration_code: 'auction001')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>püramiid.test</domain:name>
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

    @idn_auction.reload
    assert @idn_auction.domain_registered?
    assert Domain.where(name: @idn_auction.domain).exists?
    assert_epp_response :completed_successfully
  end

  def test_registers_ascii_domain_with_correct_registration_code_when_payment_is_received
    @idn_auction.update!(status: Auction.statuses[:payment_received],
                     registration_code: 'auction001')

    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <create>
            <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>xn--pramiid-n2a.test</domain:name>
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

    @idn_auction.reload
    assert @idn_auction.domain_registered?
    assert Domain.where(name: @idn_auction.domain).exists?
    assert_epp_response :completed_successfully
  end
end
