require 'test_helper'

class NameserverRecordValidationJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @nameserver = nameservers(:shop_ns1)
  end

  def test_nameserver_should_be_fail_if_nameserver_not_respond
    Spy.on_instance_method(NameserverRecordValidationJob, :validate_hostname_respond).and_return(false)

    result = NameserverRecordValidationJob.perform_now(@nameserver)

    event_data = {
      "errors" => "",
      "check_level" => 'ns',
      "email" => "",
      "reason" => "Nameserver doesn't respond"
    }

    assert_equal result.event_data, event_data
    assert_equal result.success, false
    assert_equal result.validation_eventable_type, "Nameserver"
    assert_equal result.validation_eventable_id, @nameserver.id
    assert_equal result.event_type.instance_variable_get("@event_type"), "nameserver_validation"
  end

  def test_nameserver_should_test_successful
    Spy.on_instance_method(NameserverRecordValidationJob, :validate_hostname_respond).and_return(true)

    result = NameserverRecordValidationJob.perform_now(@nameserver)

    event_data = {
      "errors" => "",
      "check_level" => 'ns',
      "email" => "",
      "reason" => ""
    }

    assert_equal result.event_data, event_data
    assert_equal result.success, true
    assert_equal result.validation_eventable_type, "Nameserver"
    assert_equal result.validation_eventable_id, @nameserver.id
    assert_equal result.event_type.instance_variable_get("@event_type"), "nameserver_validation"
  end

  def test_should_check_specific_nameserver
    nameserver_validation_job = Minitest::Mock.new
    nameserver_validation_job.expect(:validate_hostname_respond, true, [@nameserver])

    NameserverRecordValidationJob.stub :perform_now, nameserver_validation_job do
      assert_equal nameserver_validation_job.validate_hostname_respond(@nameserver), true
    end
  end
end
