require 'test_helper'

class NameserverRecordValidationJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @nameserver = nameservers(:shop_ns1)
  end

  def test_nameserver_should_send_notification_if_nameserver_is_failed
    Spy.on_instance_method(NameserverRecordValidationJob, :validate).and_return(false)

    assert_difference 'Notification.count' do
      NameserverRecordValidationJob.perform_now(@nameserver)
    end
  end

  def test_nameserver_should_not_send_notification_if_nameserver_is_correct
    Spy.on_instance_method(NameserverRecordValidationJob, :validate).and_return(true)

    assert_no_difference 'Notification.count' do
      NameserverRecordValidationJob.perform_now(@nameserver)
    end
  end
end
