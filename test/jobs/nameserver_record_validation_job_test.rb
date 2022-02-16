require 'test_helper'

class NameserverRecordValidationJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @nameserver = nameservers(:shop_ns1)
    @domain = domains(:shop)
    @domain.update(created_at: Time.zone.now - 10.hours)
    @domain.reload
  end

  def test_nameserver_should_validate_succesfully_and_set_validation_datetime
    mock_dns_response = OpenStruct.new
    answer = OpenStruct.new
    answer.instance_variable_set(:@serial, '12345')

    mock_dns_response.answer = [ answer ]

    Spy.on_instance_method(NameserverValidator, :setup_resolver).and_return(Dnsruby::Resolver.new)
    Spy.on_instance_method(Dnsruby::Resolver, :query).and_return(mock_dns_response)

    assert_nil @nameserver.validation_datetime
    assert_nil @nameserver.validation_counter
    assert_nil @nameserver.failed_validation_reason

    NameserverRecordValidationJob.perform_now(domain_name: @domain.name)
    @nameserver.reload

    p @nameserver

    assert_not_nil @nameserver.validation_datetime
    assert_nil @nameserver.validation_counter
    assert_nil @nameserver.failed_validation_reason
  end

  def test_should_return_failed_validation_with_answer_reason
    mock_dns_response = OpenStruct.new
    mock_dns_response.answer = [ ]

    Spy.on_instance_method(NameserverValidator, :setup_resolver).and_return(Dnsruby::Resolver.new)
    Spy.on_instance_method(Dnsruby::Resolver, :query).and_return(mock_dns_response)

    assert_nil @nameserver.validation_datetime
    assert_nil @nameserver.validation_counter
    assert_nil @nameserver.failed_validation_reason

    NameserverRecordValidationJob.perform_now(domain_name: @domain.name)
    @nameserver.reload

    assert_nil @nameserver.validation_datetime
    assert @nameserver.validation_counter, 1
    assert @nameserver.failed_validation_reason.include? "No any answer comes from **#{@nameserver.hostname}**"
  end

  def test_should_return_failed_validation_with_serial_reason
    mock_dns_response = OpenStruct.new
    answer = OpenStruct.new
    answer.some_field = '12343'
    mock_dns_response.answer = [ answer ]

    Spy.on_instance_method(NameserverValidator, :setup_resolver).and_return(Dnsruby::Resolver.new)
    Spy.on_instance_method(Dnsruby::Resolver, :query).and_return(mock_dns_response)

    assert_nil @nameserver.validation_datetime
    assert_nil @nameserver.validation_counter
    assert_nil @nameserver.failed_validation_reason

    NameserverRecordValidationJob.perform_now(domain_name: @domain.name)
    @nameserver.reload

    assert_nil @nameserver.validation_datetime
    assert @nameserver.validation_counter, 1
    assert @nameserver.failed_validation_reason.include? "Serial number for nameserver hostname **#{@nameserver.hostname}** of #{@nameserver.domain.name} doesn't present in zone. SOA validation failed."
  end

  def test_after_third_invalid_times_nameserver_should_be_invalid
    mock_dns_response = OpenStruct.new
    answer = OpenStruct.new
    answer.some_field = '12343'
    answer.type = 'SOA'
    mock_dns_response.answer = [ answer ]

    Spy.on_instance_method(NameserverValidator, :setup_resolver).and_return(Dnsruby::Resolver.new)
    Spy.on_instance_method(Dnsruby::Resolver, :query).and_return(mock_dns_response)

    assert_nil @nameserver.validation_datetime
    assert_nil @nameserver.validation_counter
    assert_nil @nameserver.failed_validation_reason

    3.times do
      NameserverRecordValidationJob.perform_now(domain_name: @domain.name)
    end

    @nameserver.reload

    p @nameserver.failed_validation_reason

    assert_nil @nameserver.validation_datetime
    assert @nameserver.validation_counter, 1
    assert @nameserver.failed_validation_reason.include? "Serial number for nameserver hostname **#{@nameserver.hostname}** of #{@nameserver.domain.name} doesn't present in zone. SOA validation failed."

    assert @nameserver.failed_validation?
  end
end
