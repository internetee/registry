require 'test_helper'
require 'support/epp/auto_renew'

class EppDomainAutoRenewTest < EppTestCase
  include EppAutoRenewSupport

  setup do
    travel_to Time.zone.now
    ENV['shunter_default_adapter'].constantize.new.clear!
    @feature = ENV['auto_renew_enabled']
    ENV['auto_renew_enabled'] = 'true'
    @verification = Setting.request_confirmation_on_registrant_change_enabled
    @ds_data = Setting.ds_data_allowed
    @key_data = Setting.key_data_allowed
    @session = epp_sessions(:api_bestnames)
    @session.update!(ext_uris: [AUTO_RENEW_URI, RGP_URI])
    @domain = domains(:shop)
    @domain.update_columns(statuses: [DomainStatus::OK], valid_to: 1.year.from_now,
                           outzone_at: nil, delete_date: nil, force_delete_date: nil)
  end

  teardown do
    ENV['auto_renew_enabled'] = @feature
    Setting.request_confirmation_on_registrant_change_enabled = @verification
    Setting.ds_data_allowed = @ds_data
    Setting.key_data_allowed = @key_data
  end

  def test_create_omitted_defaults_to_false_without_extension_response
    create_domain(nil)
    assert_code 1000
    assert_not Domain.find_by!(name: 'auto-renew.test').auto_renew?
    assert_empty response_xml.xpath('//ar:creData', ar: AUTO_RENEW_URI)
  end

  def test_create_true_and_false
    [true, false].each do |enabled|
      name = "auto-renew-#{enabled}.test"
      create_domain(enabled.to_s, name: name)
      assert_code 1000
      assert_equal enabled, Domain.find_by!(name: name).auto_renew?
      assert_equal enabled.to_s, response_xml.at_xpath('//ar:creData/ar:enabled', ar: AUTO_RENEW_URI).text
    end
  end

  def test_create_invalid_boolean_and_reversal_are_rejected
    assert_no_difference 'Domain.count' do
      create_domain('yes')
      assert_code 2005
    end
    assert_no_difference 'Domain.count' do
      create_domain(nil, extension: auto_renew_extension(:create, '<autoRenew:reverse cycleId="cycle"/>'))
      assert_code 2306
    end
  end

  def test_create_feature_off_rejects_opt_in_but_accepts_false_and_omission
    ENV['auto_renew_enabled'] = 'false'
    assert_no_difference 'Domain.count' do
      create_domain('true')
      assert_code 2306
    end
    create_domain('false', name: 'auto-renew-false.test')
    assert_code 1000
    create_domain(nil, name: 'auto-renew-omitted.test')
    assert_code 1000
  end

  def test_update_omitted_leaves_preference_and_has_no_extension_response
    @domain.update_column(:auto_renew, true)
    update_domain
    assert_code 1000
    assert @domain.reload.auto_renew?
    assert_empty response_xml.xpath('//ar:updData', ar: AUTO_RENEW_URI)
  end

  def test_update_enables_and_disables_without_reversing_paid_cycle
    cycle = auto_renew_cycle(@domain)
    expiry = @domain.valid_to
    update_domain('<autoRenew:enabled>false</autoRenew:enabled>')
    assert_code 1000
    assert_not @domain.reload.auto_renew?
    assert_equal expiry, @domain.valid_to
    assert_equal DomainAutoRenewal::GRACE, cycle.reload.state
    assert_equal 'false', response_xml.at_xpath('//ar:updData/ar:enabled', ar: AUTO_RENEW_URI).text
    update_domain('<autoRenew:enabled>true</autoRenew:enabled>')
    assert_code 1000
    assert @domain.reload.auto_renew?
    assert_equal 'true', response_xml.at_xpath('//ar:updData/ar:enabled', ar: AUTO_RENEW_URI).text
  end

  def test_update_false_cancels_funding_retry
    cycle = auto_renew_cycle(@domain, state: DomainAutoRenewal::AWAITING_FUNDS, renewed_expire_at: nil)
    update_domain('<autoRenew:enabled>false</autoRenew:enabled>')
    assert_code 1000
    assert_equal DomainAutoRenewal::CANCELLED, cycle.reload.state
  end

  def test_update_feature_off_and_invalid_boolean
    ENV['auto_renew_enabled'] = 'false'
    update_domain('<autoRenew:enabled>true</autoRenew:enabled>')
    assert_code 2306
    assert_not @domain.reload.auto_renew?
    update_domain('<autoRenew:enabled>yes</autoRenew:enabled>')
    assert_code 2005
    update_domain('<autoRenew:enabled>false</autoRenew:enabled>')
    assert_code 1000
  end

  def test_duplicate_update_blocks_are_rejected
    extension = auto_renew_extension(:update, '<autoRenew:enabled>true</autoRenew:enabled>')
    send_command(:update, "<domain:name>#{@domain.name}</domain:name>", extension + extension)
    assert_code 2001
    assert_not @domain.reload.auto_renew?
  end

  def test_reversal_refunds_once_and_returns_repeated_result
    cycle = auto_renew_cycle(@domain, charge: true)
    ENV['auto_renew_enabled'] = 'false'
    balance = cycle.account.reload.balance
    assert_difference 'AccountActivity.count', 1 do
      update_domain("<autoRenew:reverse cycleId=\"#{cycle.uuid}\"/>")
      assert_code 1000
    end
    assert_equal cycle.original_expire_at, @domain.reload.valid_to
    assert_not @domain.auto_renew?
    assert_equal balance + 12, cycle.account.reload.balance
    reversed = response_xml.at_xpath('//ar:reversed', ar: AUTO_RENEW_URI)
    assert_equal cycle.uuid, reversed['cycleId']
    assert_equal '12.00', reversed['refund']
    assert_equal 'EUR', reversed['currency']
    assert_equal 'false', reversed['repeated']
    assert_no_difference 'AccountActivity.count' do
      update_domain("<autoRenew:reverse cycleId=\"#{cycle.uuid}\"/>")
      assert_code 1000
    end
    assert_equal 'true', response_xml.at_xpath('//ar:reversed', ar: AUTO_RENEW_URI)['repeated']
    assert_equal balance + 12, cycle.account.reload.balance
  end

  def test_expired_cycle_reversal_rolls_back_other_changes
    cycle = auto_renew_cycle(@domain, cancellation_deadline_at: Time.zone.now)
    expiry = @domain.valid_to
    nameservers = @domain.nameservers.pluck(:hostname)
    update_domain("<autoRenew:reverse cycleId=\"#{cycle.uuid}\"/>", body: nameserver_add)
    assert_code 2304
    assert_equal nameservers, @domain.reload.nameservers.pluck(:hostname)
    assert_equal expiry, @domain.valid_to
    assert @domain.auto_renew?
    assert_equal DomainAutoRenewal::GRACE, cycle.reload.state
  end

  def test_unknown_cycle_and_cycle_of_another_domain
    update_domain('<autoRenew:reverse cycleId="3f7c2a5e-0000-0000-0000-000000000000"/>')
    assert_code 2303
    cycle = auto_renew_cycle(domains(:airport))
    update_domain("<autoRenew:reverse cycleId=\"#{cycle.uuid}\"/>")
    assert_code 2303
  end

  def test_reversal_after_completed_registrant_change_is_not_reversible
    Setting.request_confirmation_on_registrant_change_enabled = false
    cycle = auto_renew_cycle(@domain, charge: true)
    expiry = @domain.valid_to
    balance = cycle.account.reload.balance
    body = "<domain:chg><domain:registrant>#{contacts(:william).code}</domain:registrant></domain:chg>"

    assert_no_difference ['AccountActivity.count', 'Notification.count'] do
      update_domain(body: body, legal_document: true)
      assert_code 1000
      assert_equal contacts(:william).id, @domain.reload.registrant_id
      assert_equal DomainAutoRenewal::COMPLETED, cycle.reload.state

      update_domain("<autoRenew:reverse cycleId=\"#{cycle.uuid}\"/>")
      assert_code 2304
      assert_includes response.body, I18n.t('auto_renew.errors.not_reversible')
    end

    assert_nil cycle.reload.refund_activity_id
    assert_equal balance, cycle.account.reload.balance
    assert_equal expiry, @domain.reload.valid_to
    assert @domain.auto_renew?
  end

  def test_non_sponsor_with_auth_info_cannot_change_preference
    epp_sessions(:api_goodnames).touch
    update_domain('<autoRenew:enabled>true</autoRenew:enabled>',
                  body: "<domain:chg><domain:authInfo><domain:pw>#{@domain.transfer_code}</domain:pw></domain:authInfo></domain:chg>",
                  session: 'api_goodnames')
    assert_code 2201
    assert_not @domain.reload.auto_renew?
  end

  def test_mixed_registrant_update_applies_preference_now_and_omits_it_from_replay
    Setting.request_confirmation_on_registrant_change_enabled = true
    old_registrant = @domain.registrant
    body = "<domain:chg><domain:registrant verified=\"no\">#{contacts(:william).code}</domain:registrant></domain:chg>"
    update_domain('<autoRenew:enabled>true</autoRenew:enabled>', body: body, legal_document: true)
    assert_code 1001
    assert @domain.reload.auto_renew?
    assert_equal old_registrant, @domain.registrant
    assert @domain.registrant_verification_asked?
    assert_not @domain.pending_json.fetch('frame').key?('auto_renew')
    assert_equal 'true', response_xml.at_xpath('//ar:updData/ar:enabled', ar: AUTO_RENEW_URI).text
  end

  def test_info_without_dnssec_includes_preference_and_cycle
    cycle = auto_renew_cycle(@domain)
    info_domain
    assert_code 1000
    assert_equal 'true', response_xml.at_xpath('//ar:infData/ar:enabled', ar: AUTO_RENEW_URI).text
    assert_equal cycle.uuid, response_xml.at_xpath('//ar:cycle', ar: AUTO_RENEW_URI)['id']
    assert_equal 'autoRenewPeriod', response_xml.at_xpath('//rgp:rgpStatus', rgp: RGP_URI)['s']
    assert_equal 1, response_xml.xpath('//epp:extension', epp: epp_uri).size
    assert_empty response_xml.xpath('//domain:status[@s="autoRenewPeriod"]', domain: domain_uri)
  end

  def test_info_composes_dnssec_rgp_and_auto_renew_in_one_extension
    auto_renew_cycle(@domain)
    Setting.ds_data_allowed = true
    Setting.key_data_allowed = true
    dnskeys(:one).update!(domain: @domain)
    info_domain
    assert_code 1000
    assert_equal 1, response_xml.xpath('//epp:extension', epp: epp_uri).size
    assert response_xml.at_xpath('//secDNS:infData', secDNS: 'urn:ietf:params:xml:ns:secDNS-1.1')
    assert response_xml.at_xpath('//ar:infData', ar: AUTO_RENEW_URI)
    assert response_xml.at_xpath('//rgp:infData', rgp: RGP_URI)
  end

  def test_info_without_cycle_still_reports_preference
    info_domain
    assert_code 1000
    assert_equal 'false', response_xml.at_xpath('//ar:enabled', ar: AUTO_RENEW_URI).text
    assert_empty response_xml.xpath('//ar:cycle', ar: AUTO_RENEW_URI)
    assert_empty response_xml.xpath('//rgp:infData', rgp: RGP_URI)
  end

  def test_non_sponsor_info_sees_rgp_but_never_preference_even_with_auth_info
    auto_renew_cycle(@domain)
    epp_sessions(:api_goodnames).update!(ext_uris: [AUTO_RENEW_URI, RGP_URI])
    info_domain(session: 'api_goodnames', auth_info: true)
    assert_code 1000
    assert_empty response_xml.xpath('//ar:infData', ar: AUTO_RENEW_URI)
    assert response_xml.at_xpath('//rgp:infData', rgp: RGP_URI)
  end

  def test_unnegotiated_extensions_are_not_emitted
    auto_renew_cycle(@domain)
    @session.update!(ext_uris: [])
    info_domain
    assert_code 1000
    assert_empty response_xml.xpath('//epp:extension', epp: epp_uri)
    update_domain('<autoRenew:enabled>false</autoRenew:enabled>')
    assert_code 1000
    assert_not @domain.reload.auto_renew?
    assert_empty response_xml.xpath('//ar:updData', ar: AUTO_RENEW_URI)
    create_domain('true')
    assert_code 1000
    assert_empty response_xml.xpath('//ar:creData', ar: AUTO_RENEW_URI)
  end

  def test_each_info_extension_is_negotiated_independently
    auto_renew_cycle(@domain)
    @session.update!(ext_uris: [RGP_URI])
    info_domain
    assert_code 1000
    assert response_xml.at_xpath('//rgp:infData', rgp: RGP_URI)
    assert_empty response_xml.xpath('//ar:infData', ar: AUTO_RENEW_URI)
    @session.update!(ext_uris: [AUTO_RENEW_URI])
    info_domain
    assert_code 1000
    assert response_xml.at_xpath('//ar:infData', ar: AUTO_RENEW_URI)
    assert_empty response_xml.xpath('//rgp:infData', rgp: RGP_URI)
  end

  def test_rgp_disappears_exactly_at_deadline_and_funding_retry_has_no_rgp
    cycle = auto_renew_cycle(@domain)
    cycle.update!(cancellation_deadline_at: Time.zone.now)
    info_domain
    assert_code 1000
    assert_empty response_xml.xpath('//rgp:infData', rgp: RGP_URI)
    assert_equal 'completed', response_xml.at_xpath('//ar:cycle', ar: AUTO_RENEW_URI)['state']
    cycle.update!(state: DomainAutoRenewal::AWAITING_FUNDS, renewed_expire_at: nil,
                  cancellation_deadline_at: 1.day.from_now)
    info_domain
    assert_code 1000
    assert_empty response_xml.xpath('//rgp:infData', rgp: RGP_URI)
    data = response_xml.at_xpath('//ar:cycle', ar: AUTO_RENEW_URI)
    assert_equal 'fundingRetry', data['state']
    assert_nil data['exDate']
  end

  def test_auto_renew_update_coexists_with_dnssec_nameservers_and_statuses
    Setting.key_data_allowed = true
    Setting.ds_data_allowed = false
    key = dnskeys(:one)
    dnssec = <<~XML
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:add><secDNS:keyData>
          <secDNS:flags>#{key.flags}</secDNS:flags>
          <secDNS:protocol>#{key.protocol}</secDNS:protocol>
          <secDNS:alg>#{key.alg}</secDNS:alg>
          <secDNS:pubKey>#{key.public_key}</secDNS:pubKey>
        </secDNS:keyData></secDNS:add>
      </secDNS:update>
    XML
    status = '<domain:status s="clientHold"/>'
    body = nameserver_add.sub('</domain:add>', "#{status}</domain:add>")
    extension = auto_renew_extension(:update, '<autoRenew:enabled>true</autoRenew:enabled>')
    send_command(:update, "<domain:name>#{@domain.name}</domain:name>#{body}", extension + dnssec)
    assert_code 1000
    assert @domain.reload.auto_renew?
    assert_includes @domain.nameservers.pluck(:hostname), 'ns3.example.net'
    assert_includes @domain.statuses, DomainStatus::CLIENT_HOLD
    assert_equal key.public_key, @domain.dnskeys.first.public_key
  end

  def test_legacy_info_is_identical_with_auto_renew_state_and_cycle
    @session.update!(ext_uris: [])
    info_domain
    assert_code 1000
    before = response_xml
    before.at_css('svTRID').content = 'transaction-id'
    expiry = @domain.valid_to
    @domain.update_column(:auto_renew, true)
    DomainAutoRenewal.create!(
      domain: @domain, domain_name: @domain.name, registrar: @domain.registrar,
      account: @domain.registrar.cash_account, state: DomainAutoRenewal::GRACE,
      original_expire_at: 1.day.ago, renewed_expire_at: expiry,
      cancellation_deadline_at: 14.days.from_now
    )
    info_domain
    assert_code 1000
    after = response_xml
    after.at_css('svTRID').content = 'transaction-id'
    assert_equal before.to_xml, after.to_xml
  end

  def test_failed_renewal_info_keeps_preference_without_rgp_and_rejects_reversal
    original_expiry = Time.zone.now
    @domain.update_columns(auto_renew: true, valid_to: original_expiry,
                           statuses: [DomainStatus::EXPIRED, DomainStatus::SERVER_HOLD],
                           status_notes: {}, outzone_at: 1.day.ago, delete_date: 29.days.from_now)
    billing_prices(:renew_one_year).update!(valid_from: original_expiry.beginning_of_year, valid_to: nil)
    cycle = Domains::AutoRenew::OpenCycle.run!(domain: @domain)
    @domain.registrar.cash_account.update!(balance: 0)
    Domains::AutoRenew::AttemptRenewal.run!(cycle: cycle)
    travel_to cycle.cancellation_deadline_at
    DomainCron.process_auto_renewals
    @session.touch

    info_domain
    assert_code 1000
    assert_equal 'true', response_xml.at_xpath('//ar:enabled', ar: AUTO_RENEW_URI).text
    data = response_xml.at_xpath('//ar:cycle', ar: AUTO_RENEW_URI)
    assert_equal 'failed', data['state']
    assert_nil data['exDate']
    assert_empty response_xml.xpath('//rgp:infData', rgp: RGP_URI)
    assert_equal original_expiry, @domain.reload.valid_to
    assert_no_difference 'AccountActivity.count' do
      update_domain("<autoRenew:reverse cycleId=\"#{cycle.uuid}\"/>")
      assert_code 2304
    end
    assert @domain.reload.auto_renew?
    assert_nil cycle.reload.refund_activity_id
  end

  private

  def response_xml
    Nokogiri::XML(response.body)
  end

  def assert_code(code)
    assert_equal code.to_s, response_xml.at_css('result')['code'], response.body
    assert_correct_against_schema response_xml
  end

  def send_command(command, body, extension = nil, session: 'api_bestnames')
    post "/epp/command/#{command}", params: { frame: auto_renew_command(command, body, extension) },
                                    headers: { 'HTTP_COOKIE' => "session=#{session}" }
  end

  def update_domain(children = nil, body: '', session: 'api_bestnames', legal_document: false)
    extension = auto_renew_extension(:update, children) if children
    extension = "#{extension}#{legal_document_extension}" if legal_document
    send_command(:update, "<domain:name>#{@domain.name}</domain:name>#{body}", extension, session: session)
  end

  def create_domain(value, name: 'auto-renew.test', extension: nil)
    extension ||= auto_renew_extension(:create, "<autoRenew:enabled>#{value}</autoRenew:enabled>") unless value.nil?
    body = <<~XML
      <domain:name>#{name}</domain:name>
      <domain:ns>
        <domain:hostAttr><domain:hostName>ns1.example.net</domain:hostName></domain:hostAttr>
        <domain:hostAttr><domain:hostName>ns2.example.net</domain:hostName></domain:hostAttr>
      </domain:ns>
      <domain:registrant>#{contacts(:john).code}</domain:registrant>
      <domain:contact type="admin">#{contacts(:jane).code}</domain:contact>
    XML
    send_command(:create, body, "#{extension}#{legal_document_extension}")
  end

  def info_domain(session: 'api_bestnames', auth_info: false)
    body = "<domain:name>#{@domain.name}</domain:name>"
    body += "<domain:authInfo><domain:pw>#{@domain.transfer_code}</domain:pw></domain:authInfo>" if auth_info
    send_command(:info, body, nil, session: session)
  end

  def legal_document_extension
    <<~XML
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
      </eis:extdata>
    XML
  end

  def nameserver_add
    '<domain:add><domain:ns><domain:hostAttr><domain:hostName>ns3.example.net</domain:hostName></domain:hostAttr></domain:ns></domain:add>'
  end

  def epp_uri
    'https://epp.tld.ee/schema/epp-ee-1.0.xsd'
  end

  def domain_uri
    'https://epp.tld.ee/schema/domain-ee-1.2.xsd'
  end
end
