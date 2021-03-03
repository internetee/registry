require "test_helper"

class RegistrantChangeExpiredEmailJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
    @domain = domains(:shop)
  end

  def test_delivers_email
    # This job doesn't use anymore, but I'll leave it here for statistics
    assert RegistrantChangeExpiredEmailJob.enqueue(@domain.id)
    assert_emails 0
  end
end