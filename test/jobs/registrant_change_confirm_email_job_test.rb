require 'test_helper'

class RegistrantChangeConfirmEmailJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  def test_delivers_email
    domain_id = domains(:shop).id
    new_registrant_id = contacts(:william).id

    RegistrantChangeConfirmEmailJob.perform_now(domain_id, new_registrant_id)

    assert_emails 1
  end
end
