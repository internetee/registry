require 'test_helper'

class EppDomainTransferRequestTest < ApplicationIntegrationTest
  def setup
    @domain = domains(:shop)
    @new_registrar = registrars(:goodnames)
    @original_transfer_wait_time = Setting.transfer_wait_time
    Setting.transfer_wait_time = 0
  end

  def teardown
    Setting.transfer_wait_time = @original_transfer_wait_time
  end

  def test_transfers_domain_at_once
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    assert_equal '1000', Nokogiri::XML(response.body).at_css('result')[:code]
    assert_equal 1, Nokogiri::XML(response.body).css('result').size
  end

  def test_creates_new_domain_transfer
    assert_difference -> { @domain.transfers.size } do
      post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    end
  end

  def test_approves_automatically_if_auto_approval_is_enabled
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    assert_equal 'serverApproved', Nokogiri::XML(response.body).xpath('//domain:trStatus', 'domain' =>
      'https://epp.tld.ee/schema/domain-eis-1.0.xsd').text
  end

  def test_assigns_new_registrar
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    @domain.reload
    assert_equal @new_registrar, @domain.registrar
  end

  def test_regenerates_transfer_code
    @old_transfer_code = @domain.transfer_code

    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }

    @domain.reload
    refute_equal @domain.transfer_code, @old_transfer_code
  end

  def test_notifies_old_registrar
    @old_registrar = @domain.registrar

    assert_difference -> { @old_registrar.messages.count } do
      post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    end
  end

  def test_duplicates_registrant_admin_and_tech_contacts
    assert_difference -> { @new_registrar.contacts.size }, 3 do
      post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    end
  end

  def test_reuses_identical_contact
    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    assert_equal 1, @new_registrar.contacts.where(name: 'William').size
  end

  def test_saves_legal_document
    assert_difference -> { @domain.legal_documents(true).size } do
      post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    end
  end

  def test_non_transferable_domain
    @domain.update!(statuses: [DomainStatus::SERVER_TRANSFER_PROHIBITED])

    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    domains(:shop).reload

    assert_equal registrars(:bestnames), domains(:shop).registrar
    assert_equal '2304', Nokogiri::XML(response.body).at_css('result')[:code]
  end

  def test_discarded_domain_cannot_be_transferred
    travel_to Time.zone.parse('2010-07-05 10:30')
    @domain.delete_at = Time.zone.parse('2010-07-05 10:00')
    @domain.discard

    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    @domain.reload

    assert_equal registrars(:bestnames), @domain.registrar
    assert_equal '2105', Nokogiri::XML(response.body).at_css('result')[:code]
    travel_back
  end

  def test_same_registrar
    assert_no_difference -> { @domain.transfers.size } do
      post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_bestnames' }
    end

    assert_equal '2002', Nokogiri::XML(response.body).at_css('result')[:code]
  end

  def test_wrong_transfer_code
    request_xml = <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="request">
            <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw>wrong</domain:pw>
              </domain:authInfo>
            </domain:transfer>
          </transfer>
        </command>
      </epp>
    XML

    post '/epp/command/transfer', { frame: request_xml }, { 'HTTP_COOKIE' => 'session=api_goodnames' }
    @domain.reload
    refute_equal @new_registrar, @domain.registrar
    assert_equal '2201', Nokogiri::XML(response.body).at_css('result')[:code]
  end

  private

  def request_xml
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <transfer op="request">
            <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
              <domain:name>shop.test</domain:name>
              <domain:authInfo>
                <domain:pw>65078d5</domain:pw>
              </domain:authInfo>
            </domain:transfer>
          </transfer>
          <extension>
            <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
              <eis:legalDocument type="pdf">test</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
  end
end
