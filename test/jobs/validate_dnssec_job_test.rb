require 'test_helper'

class ZoneAnswer
  def initialize(valid_response: true)
    @answer = []

    algorithm = OpenStruct.new(code: 13)

    answer = OpenStruct.new
    answer.data = "some0 some1 some2 257 some4 some5 some6 mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ== some"
    answer.flags = 257
    answer.protocol = 3
    answer.protocol = 7 unless valid_response
    answer.algorithm = algorithm

    @answer << answer
  end

  def each_answer
    @answer.each {|rec|
      yield rec
    }
  end
end

class ValidateDnssecJobTest < ActiveJob::TestCase
  setup do
    @domain = domains(:shop)
    @dnskey = dnskeys(:one)
  end

  def test_job_should_set_validation_datetime_if_validation_is_valid
    @domain.nameservers.each do |n|
      n.update(validation_datetime: Time.zone.now - 1.minute)
    end
    @domain.dnskeys << @dnskey
    @domain.save

    @domain.reload

    mock_zone_data = ZoneAnswer.new

    Spy.on_instance_method(ValidateDnssecJob, :prepare_validator).and_return(Dnsruby::Resolver.new)
    Spy.on_instance_method(Dnsruby::Resolver, :query).and_return(mock_zone_data)

    ValidateDnssecJob.perform_now(domain_name: @domain.name)

    @domain.reload
    assert_not_nil @domain.dnskeys.first.validation_datetime
  end

  def test_job_should_not_set_validation_datetime_if_validation_is_invalid
    @domain.nameservers.each do |n|
      n.update(validation_datetime: Time.zone.now - 1.minute)
    end
    @domain.dnskeys << @dnskey
    @domain.save

    @domain.reload

    mock_zone_data = ZoneAnswer.new(valid_response: false)

    Spy.on_instance_method(ValidateDnssecJob, :prepare_validator).and_return(Dnsruby::Resolver.new)
    Spy.on_instance_method(Dnsruby::Resolver, :query).and_return(mock_zone_data)

    ValidateDnssecJob.perform_now(domain_name: @domain.name)

    @domain.reload
    assert_nil @domain.dnskeys.first.validation_datetime
  end
end
