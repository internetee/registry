require 'test_helper'

class NameserverRecordValidationJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @nameserver = nameservers(:shop_ns1)
  end

  def test_should_check_all_nameserver
    result = NameserverRecordValidationJob.perform_now
    assert_equal result.count, Nameserver.count
  end

  def test_should_check_specific_nameserver
    nameserver_validation_job = Minitest::Mock.new
    nameserver_validation_job.expect(:validate_hostname, true, [@nameserver])

    NameserverRecordValidationJob.stub :perform_now, nameserver_validation_job do
      assert_equal nameserver_validation_job.validate_hostname(@nameserver), true
    end
  end
end
