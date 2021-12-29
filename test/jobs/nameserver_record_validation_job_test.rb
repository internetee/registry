require 'test_helper'

class NameserverRecordValidationJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @nameserver = nameservers(:shop_ns1)
    Spy.on_instance_method(Domains::NameserverValidator, :run).and_return({result: true, reason: ''})
  end
end
