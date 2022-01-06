$VERBOSE=nil
require 'test_helper'

class ValidateDnssecJobTest < ActiveJob::TestCase
  setup do
    @domain = domains(:shop)
    @dnskey = dnskeys(:one)
  end

  def test_job_should_return_successfully_validated_dnskeys
    # @domain.dnskeys << @dnskey
    # @domain.save
    # @domain.reload
    #
    # mock_zone_data = [
    #   {
    #     flags: @dnskey.flags,
    #     protocol: @dnskey.protocol,
    #     alg: @dnskey.alg,
    #     public_key: @dnskey.public_key
    #   }]
    #
    # resolver = Spy.mock(Dnsruby::Recursor)
    # Spy.on(resolver, :query).and_return true
    # Spy.on_instance_method(ValidateDnssecJob, :parse_response).and_return(mock_zone_data)
    # # Spy.on_instance_method(ValidateDnssecJob, :prepare_validator).and_return(true)
    #
    #
    # ValidateDnssecJob.perform_now(domain_name: @domain.name)
    #
    # @domain.reload
    # p @domain.dnskeys
  end

  # def test_job_discarded_after_error
  #   assert_no_enqueued_jobs
  #   assert_performed_jobs 1 do
  #     TestDiscardedJob.perform_later
  #   end
  #   assert_no_enqueued_jobs
  # end
end
