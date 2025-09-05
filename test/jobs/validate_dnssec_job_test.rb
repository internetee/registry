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

  def test_prepare_validator_configures_dnsruby_resolver_with_correct_parameters
    job = ValidateDnssecJob.new
    
    original_timeout = ENV['nameserver_validation_timeout']
    
    # Timout set for current test - in given time DNSSEC validation should be finished
    ENV['nameserver_validation_timeout'] = '4'
    
    resolver = job.send(:prepare_validator, "8.8.8.8")

    assert_instance_of Dnsruby::Resolver, resolver
    
    assert resolver.do_validation
    assert resolver.dnssec
    assert_equal 4, resolver.packet_timeout
    assert_equal 4, resolver.query_timeout
    
    ENV['nameserver_validation_timeout'] = original_timeout
  end

  def test_perform_skips_validation_if_no_nameservers_present
    domain = Domain.create!(
      name: "test.test",
      registrar: registrars(:bestnames),
      registrant: @domain.registrant,
      period: 1,
      period_unit: 'y',
      valid_to: 1.year.from_now
    )

    dnskey = @dnskey
    domain.dnskeys << dnskey

    original_validation_time = dnskey.validation_datetime

    ValidateDnssecJob.new.perform(domain_name: domain.name)

    dnskey.reload
    assert_equal dnskey.validation_datetime, dnskey.validation_datetime, "Expected DNSKEY validation_datetime to be set after successful validation"
  end

  def test_perform_updates_dnskey_validation_if_nameservers_present
    domain = Domain.create!(
      name: "test.test",
      registrar: registrars(:bestnames),
      registrant: @domain.registrant,
      period: 1,
      period_unit: 'y',
      valid_to: 1.year.from_now
    )

    dnskey = @dnskey
    domain.dnskeys << dnskey

    nameserver = domain.nameservers.create!(
      hostname: 'ns1.test.test',
      ipv4: ['192.0.2.1']
    )
    
    nameserver.update(validation_datetime: Time.zone.now - 1.minute)

    mock_zone_data = ZoneAnswer.new
    Spy.on_instance_method(ValidateDnssecJob, :prepare_validator).and_return(Dnsruby::Resolver.new)
    Spy.on_instance_method(Dnsruby::Resolver, :query).and_return(mock_zone_data)

    ValidateDnssecJob.perform_now(domain_name: domain.name)
  
    dnskey.reload
    assert_not_nil dnskey.validation_datetime, "Expected DNSKEY validation_datetime to be set after successful validation"
  end

  def perform_without_domain_name_executes_else_block
    domain = domains(:shop)

    domain.dnskeys << @dnskey unless domain.dnskeys.any?
    
    # Add nameserver if not present
    unless domain.nameservers.any?
      domain.nameservers.create!(
        hostname: "ns.#{domain.name}",
        ipv4: ["192.0.2.1"],
        validation_datetime: Time.zone.now
      )
    end
  
    ValidateDnssecJob.perform_now
  end
end
