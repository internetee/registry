require 'test_helper'
require 'support/epp/auto_renew'

class EppAutoRenewPollTest < EppTestCase
  include EppAutoRenewSupport

  setup do
    ENV['shunter_default_adapter'].constantize.new.clear!
    travel_to Time.zone.now
    @session = epp_sessions(:api_bestnames)
    @session.update!(ext_uris: [AUTO_RENEW_URI])
    @domain = domains(:shop)
    @domain.update_columns(statuses: [DomainStatus::OK], outzone_at: nil,
                           delete_date: nil, force_delete_date: nil)
    @cycle = auto_renew_cycle(@domain, charge: true)
    @domain.registrar.notifications.delete_all(:delete_all)
    @notification = @domain.registrar.notifications.create!(
      event: 'renewed', text: "Automatically renewed #{@domain.name}",
      attached_obj_type: 'DomainAutoRenewal', attached_obj_id: @cycle.id
    )
  end

  def test_poll_returns_text_and_negotiated_cycle_extension_without_res_data
    request_poll
    assert_equal '1301', response_xml.at_css('result')['code']
    assert_equal @notification.text, response_xml.at_css('msgQ > msg').text
    assert_empty response_xml.xpath('//epp:resData', epp: epp_uri)
    poll_data = response_xml.at_xpath('//ar:pollData', ar: AUTO_RENEW_URI)
    assert_equal 'renewed', poll_data['event']
    assert_equal @domain.name, poll_data.at_xpath('ar:name', ar: AUTO_RENEW_URI).text
    assert_equal @cycle.uuid, poll_data.at_xpath('ar:cycle', ar: AUTO_RENEW_URI)['id']
    assert_correct_against_schema response_xml
  end

  def test_poll_always_returns_text_for_sessions_without_negotiation
    @session.update!(ext_uris: [])
    request_poll
    assert_equal '1301', response_xml.at_css('result')['code']
    assert_equal @notification.text, response_xml.at_css('msgQ > msg').text
    assert_empty response_xml.xpath('//epp:extension', epp: epp_uri)
    assert_correct_against_schema response_xml
  end

  def test_poll_renders_funding_events_and_omits_unset_renewed_expiry
    [
      [DomainAutoRenewal::AWAITING_FUNDS, DomainAutoRenewal::INSUFFICIENT_FUNDS, 'fundingWarning'],
      [DomainAutoRenewal::AWAITING_FUNDS, DomainAutoRenewal::RENEW_PROHIBITED, 'renewProhibited'],
      [DomainAutoRenewal::AWAITING_FUNDS, DomainAutoRenewal::MISSING_PRICE, 'renewProhibited'],
      [DomainAutoRenewal::FUNDING_FAILED, DomainAutoRenewal::INSUFFICIENT_FUNDS, 'fundingFailed'],
    ].each do |state, reason, event|
      @cycle.update!(state: state, failure_reason: reason, renewed_expire_at: nil)
      @notification.update!(event: event)
      request_poll
      assert_equal event, response_xml.at_xpath('//ar:pollData', ar: AUTO_RENEW_URI)['event']
      assert_nil response_xml.at_xpath('//ar:cycle', ar: AUTO_RENEW_URI)['exDate']
      assert_correct_against_schema response_xml
    end
  end

  def test_queued_funding_warning_keeps_its_event_after_success_cancellation_and_closure
    @notification.update!(event: 'fundingWarning', text: 'Insufficient funds for automatic renewal')
    [DomainAutoRenewal::GRACE, DomainAutoRenewal::CANCELLED, DomainAutoRenewal::FUNDING_FAILED].each do |state|
      @cycle.update!(state: state, failure_reason: nil)
      travel_to Time.zone.now + 1.second
      request_poll
      poll_data = response_xml.at_xpath('//ar:pollData', ar: AUTO_RENEW_URI)
      assert_equal 'fundingWarning', poll_data['event']
      assert_correct_against_schema response_xml
    end
  end

  def test_legacy_notification_without_event_returns_text_without_auto_renew_extension
    @notification.update!(event: nil)
    request_poll
    assert_equal @notification.text, response_xml.at_css('msgQ > msg').text
    assert_empty response_xml.xpath('//ar:pollData', ar: AUTO_RENEW_URI)
    assert_correct_against_schema response_xml
  end

  private

  def request_poll
    post epp_poll_path, params: { frame: "<epp xmlns=\"#{epp_uri}\"><command><poll op=\"req\"/></command></epp>" },
                        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
  end

  def response_xml
    Nokogiri::XML(response.body)
  end

  def epp_uri
    'https://epp.tld.ee/schema/epp-ee-1.0.xsd'
  end
end
