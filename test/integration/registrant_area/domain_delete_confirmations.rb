require 'test_helper'

class RegistrantAreaDomainDeleteConfirmationIntegrationTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    ActionMailer::Base.deliveries.clear
  end

  def test_notifies_registrant_by_email_when_accepted
    @domain.update!(registrant_verification_asked_at: Time.zone.now,
                    registrant_verification_token: 'test',
                    statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])

    patch registrant_domain_delete_confirm_path(@domain, token: 'test', confirmed: true)

    assert_emails 1
  end

  def test_notifies_registrant_by_email_when_rejected
    @domain.update!(registrant_verification_asked_at: Time.zone.now,
                    registrant_verification_token: 'test',
                    statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])

    patch registrant_domain_delete_confirm_path(@domain, token: 'test', rejected: true)

    assert_emails 1
  end
end