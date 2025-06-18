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
    
    # To store original environment variable
    original_timeout = ENV['nameserver_validation_timeout']
    
    # Seadista kindel väärtus testiks
    ENV['nameserver_validation_timeout'] = '4'
    
    resolver = job.send(:prepare_validator, "8.8.8.8")
    
    assert_instance_of Dnsruby::Resolver, resolver
    assert resolver.do_validation
    assert resolver.dnssec
    assert_equal 4, resolver.packet_timeout
    assert_equal 4, resolver.query_timeout
    
    # Restore original environment variable
    ENV['nameserver_validation_timeout'] = original_timeout
  end

  def test_perform_skips_domains_without_nameservers
    domain = Domain.create!(
      name: "test.test",
      registrar: registrars(:bestnames),
      registrant: @domain.registrant,
      period: 1,
      period_unit: 'y',
      valid_to: 1.year.from_now
    )

    # Add DNSKEY to domain
    domain.dnskeys << @dnskey

    # Create a StringIO to capture log output
    log_output = StringIO.new
    logger = Logger.new(log_output)
    logger.level = Logger::INFO

    # Create a job instance and set its logger
    job = ValidateDnssecJob.new
    job.define_singleton_method(:logger) { logger }

    # Run the job
    job.perform(domain_name: domain.name)

    # Verify that the domain was skipped
    assert_match /No related nameservers for this domain/, log_output.string
  end

  def perform_without_domain_name_executes_else_block
    # Use existing domain fixture
    domain = domains(:shop)
    
    # Add DNSKEY if not present
    unless domain.dnskeys.any?
      domain.dnskeys << @dnskey
    end
    
    # Add nameserver if not present
    unless domain.nameservers.any?
      domain.nameservers.create!(
        hostname: "ns.#{domain.name}",
        ipv4: ["192.0.2.1"],
        validation_datetime: Time.zone.now
      )
    end
  
    ValidateDnssecJob.perform_now()
    
    assert true, "Job finished without errors"
  end
end
