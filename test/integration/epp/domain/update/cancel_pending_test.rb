require 'test_helper'

class EppDomainUpdateCancelPendingTest < EppTestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  setup do
    @domain = domains(:shop)
    @original_registrant_change_verification =
      Setting.request_confirmation_on_registrant_change_enabled
    Setting.request_confirmation_on_registrant_change_enabled = true
    ActionMailer::Base.deliveries.clear

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  teardown do
    Setting.request_confirmation_on_registrant_change_enabled =
      @original_registrant_change_verification
  end

  def test_cancels_pending_update_when_current_registrant_is_requested_again
    request_registrant_change
    old_registrant = @domain.registrant

    post_domain_update(old_registrant)

    assert_epp_response :completed_successfully
    assert_equal old_registrant, @domain.registrant
    assert_not_includes @domain.statuses, DomainStatus::PENDING_UPDATE
    assert_empty @domain.pending_json
    assert_not @domain.registrant_verification_asked?
  end

  def test_notifies_both_registrants_when_pending_update_is_cancelled
    request_registrant_change
    new_registrant_email = @domain.new_registrant_email
    registrant_email = @domain.registrant.email
    ActionMailer::Base.deliveries.clear

    perform_enqueued_jobs { post_domain_update(@domain.registrant) }

    email = ActionMailer::Base.deliveries.last
    assert_includes email.to, new_registrant_email
    assert_includes email.to, registrant_email
  end

  def test_rejects_update_of_pending_domain_when_another_registrant_is_requested
    request_registrant_change
    old_registrant = @domain.registrant

    post_domain_update(contacts(:jack))

    assert_epp_response :object_status_prohibits_operation
    assert_equal old_registrant, @domain.registrant
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def test_does_not_cancel_pending_update_when_other_changes_are_requested
    request_registrant_change
    old_transfer_code = @domain.transfer_code

    post_domain_update(@domain.registrant, transfer_code: 'new-transfer-code')

    assert_epp_response :object_status_prohibits_operation
    assert_equal old_transfer_code, @domain.transfer_code
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def test_keeps_regular_update_intact_when_domain_has_no_pending_update
    assert_not_includes @domain.statuses, DomainStatus::PENDING_UPDATE

    post_domain_update(@domain.registrant)

    assert_epp_response :completed_successfully
    assert_not_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  private

  def request_registrant_change
    new_registrant = contacts(:william)
    assert_not_equal new_registrant, @domain.registrant

    post_domain_update(new_registrant)

    assert_epp_response :completed_successfully_action_pending
    assert_includes @domain.statuses, DomainStatus::PENDING_UPDATE
  end

  def post_domain_update(registrant, transfer_code: nil)
    post epp_update_path,
         params: { frame: registrant_change_xml(registrant, transfer_code: transfer_code) },
         headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

    # assert_epp_response memoizes the parsed response, reset it between requests
    @epp_response = nil
    @domain.reload
  end

  def registrant_change_xml(registrant, transfer_code: nil)
    auth_info = if transfer_code
                  "<domain:authInfo><domain:pw>#{transfer_code}</domain:pw></domain:authInfo>"
                end

    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <epp xmlns="#{Xsd::Schema.filename(for_prefix: 'epp-ee', for_version: '1.0')}">
        <command>
          <update>
            <domain:update xmlns:domain="#{Xsd::Schema.filename(for_prefix: 'domain-ee', for_version: '1.2')}">
              <domain:name>#{@domain.name}</domain:name>
              <domain:chg>
                <domain:registrant verified="no">#{registrant.code}</domain:registrant>
                #{auth_info}
              </domain:chg>
            </domain:update>
          </update>
          <extension>
            <eis:extdata xmlns:eis="#{Xsd::Schema.filename(for_prefix: 'eis', for_version: '1.0')}">
              <eis:legalDocument type="pdf">#{'test' * 2000}</eis:legalDocument>
            </eis:extdata>
          </extension>
        </command>
      </epp>
    XML
  end
end
