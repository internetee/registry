require 'test_helper'

class ListingCompanyCodesResolverTest < ActiveSupport::TestCase
  Company = Struct.new(:registration_number, :company_name)

  setup do
    Rails.cache.clear
    @user = users(:registrant)
    @logger = Logger.new(StringIO.new)
  end

  def test_returns_empty_when_ident_contains_dash
    user = RegistrantUser.new(registrant_ident: 'EE-12-34', username: 'Test')
    user.save!(validate: false)

    stub = build_stub(expected_result: :should_not_be_called)
    resolver = build_resolver(user: user, company_register: stub)

    assert_equal [], resolver.call
  ensure
    user&.destroy
  end

  def test_live_success_returns_codes_and_writes_stale_cache
    companies = [Company.new('1234567', 'ACME'), Company.new('7654321', 'Globex')]
    stub = build_stub(expected_result: companies)

    resolver = build_resolver(company_register: stub)
    result = resolver.call

    assert_equal %w[1234567 7654321], result
    assert_equal %w[1234567 7654321], Rails.cache.read(stale_key)
  end

  def test_live_success_with_empty_result
    stub = build_stub(expected_result: [])
    resolver = build_resolver(company_register: stub)

    result = resolver.call

    assert_equal [], result
    assert_equal [], Rails.cache.read(stale_key)
  end

  def test_live_success_deduplicates_and_compacts
    companies = [Company.new('1234567', 'ACME'), Company.new(nil, 'NoCode'), Company.new('1234567', 'ACME Dup')]
    stub = build_stub(expected_result: companies)

    resolver = build_resolver(company_register: stub)
    result = resolver.call

    assert_equal %w[1234567], result
  end

  def test_stale_fallback_on_not_available_error
    stale_codes = %w[1234567]
    Rails.cache.write(stale_key, stale_codes, expires_in: 1.hour)

    stub = build_stub(raise_error: CompanyRegister::NotAvailableError)
    resolver = build_resolver(company_register: stub)

    assert_equal stale_codes, resolver.call
  end

  def test_empty_after_error_when_no_stale
    stub = build_stub(raise_error: CompanyRegister::NotAvailableError)
    resolver = build_resolver(company_register: stub)

    assert_equal [], resolver.call
  end

  def test_expired_stale_returns_empty
    Rails.cache.write(stale_key, %w[1234567], expires_in: 1.second)
    sleep 1.1

    stub = build_stub(raise_error: CompanyRegister::NotAvailableError)
    resolver = build_resolver(company_register: stub)

    assert_equal [], resolver.call
  end

  def test_soap_fault_returns_empty_without_stale_fallback
    Rails.cache.write(stale_key, %w[1234567], expires_in: 1.hour)

    stub = build_stub(raise_error: CompanyRegister::SOAPFaultError)
    resolver = build_resolver(company_register: stub)

    assert_equal [], resolver.call
  end

  def test_cache_write_failure_returns_live_result
    companies = [Company.new('1234567', 'ACME')]

    failing_cache = Object.new
    failing_cache.define_singleton_method(:read) { |_key| nil }
    failing_cache.define_singleton_method(:write) { |*_args| raise StandardError, 'cache down' }

    stub = build_stub(expected_result: companies)
    resolver = build_resolver(company_register: stub, cache: failing_cache)

    result = resolver.call
    assert_equal %w[1234567], result
  end

  def test_invalid_cache_period_uses_fallback_ttl
    log_output = StringIO.new
    logger = Logger.new(log_output)

    original_period = CompanyRegister.configuration.cache_period
    CompanyRegister.configuration.cache_period = 0.days

    companies = [Company.new('1234567', 'ACME')]
    stub = build_stub(expected_result: companies)
    resolver = build_resolver(company_register: stub, logger: logger)

    result = resolver.call
    assert_equal %w[1234567], result
    assert_includes log_output.string, 'invalid_cache_period'
  ensure
    CompanyRegister.configuration.cache_period = original_period
  end

  def test_logs_live_success
    log_output = StringIO.new
    logger = Logger.new(log_output)

    companies = [Company.new('1234567', 'ACME')]
    stub = build_stub(expected_result: companies)
    resolver = build_resolver(company_register: stub, logger: logger)
    resolver.call

    assert_includes log_output.string, 'live_success'
  end

  def test_logs_stale_fallback
    log_output = StringIO.new
    logger = Logger.new(log_output)
    Rails.cache.write(stale_key, %w[1234567], expires_in: 1.hour)

    stub = build_stub(raise_error: CompanyRegister::NotAvailableError)
    resolver = build_resolver(company_register: stub, logger: logger)
    resolver.call

    assert_includes log_output.string, 'stale_fallback'
  end

  def test_logs_empty_after_error
    log_output = StringIO.new
    logger = Logger.new(log_output)

    stub = build_stub(raise_error: CompanyRegister::NotAvailableError)
    resolver = build_resolver(company_register: stub, logger: logger)
    resolver.call

    assert_includes log_output.string, 'empty_after_error'
  end

  def test_logs_soap_fault
    log_output = StringIO.new
    logger = Logger.new(log_output)

    stub = build_stub(raise_error: CompanyRegister::SOAPFaultError)
    resolver = build_resolver(company_register: stub, logger: logger)
    resolver.call

    assert_includes log_output.string, 'soap_fault_direct_only'
  end

  def test_logs_cache_write_failed
    log_output = StringIO.new
    logger = Logger.new(log_output)

    failing_cache = Object.new
    failing_cache.define_singleton_method(:read) { |_key| nil }
    failing_cache.define_singleton_method(:write) { |*_args| raise StandardError, 'cache down' }

    companies = [Company.new('1234567', 'ACME')]
    stub = build_stub(expected_result: companies)
    resolver = build_resolver(company_register: stub, cache: failing_cache, logger: logger)
    resolver.call

    assert_includes log_output.string, 'cache_write_failed'
  end

  private

  def build_resolver(user: @user, company_register: nil, cache: Rails.cache, logger: @logger)
    company_register ||= build_stub(expected_result: [])
    ListingCompanyCodesResolver.new(user, cache: cache, company_register: company_register, logger: logger)
  end

  def build_stub(expected_result: nil, raise_error: nil)
    stub = Object.new

    if raise_error
      stub.define_singleton_method(:representation_rights) do |citizen_personal_code:, citizen_country_code:|
        raise raise_error
      end
    elsif expected_result == :should_not_be_called
      stub.define_singleton_method(:representation_rights) do |citizen_personal_code:, citizen_country_code:|
        raise 'representation_rights should not have been called'
      end
    else
      stub.define_singleton_method(:representation_rights) do |citizen_personal_code:, citizen_country_code:|
        expected_result
      end
    end

    stub
  end

  def stale_key
    "registrant/listing_company_codes_stale/v1/#{@user.id}"
  end
end
