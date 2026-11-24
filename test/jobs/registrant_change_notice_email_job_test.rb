require 'test_helper'

class RegistrantChangeNoticeEmailJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
    @domain = domains(:shop)
    @new_registrant_id = contacts(:william).id
  end

  def test_delivers_email
    @domain.update!(statuses: [DomainStatus::PENDING_UPDATE])

    RegistrantChangeNoticeEmailJob.perform_now(@domain.id, @new_registrant_id)

    assert_emails 1
  end

  def test_skips_email_when_registrant_change_is_no_longer_pending
    RegistrantChangeNoticeEmailJob.perform_now(@domain.id, @new_registrant_id)

    assert_emails 0
  end
end
