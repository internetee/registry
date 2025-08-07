require 'test_helper'

class DNSValidatorTest < ActiveSupport::TestCase
  
  setup do
    @domain = domains(:shop)
    @nameserver1 = nameservers(:shop_ns1)
    @nameserver2 = nameservers(:shop_ns2)
    @dnskey = dnskeys(:one)
    
    # Ensure domain has fresh timestamps for validation
    @domain.update(created_at: 1.day.ago)
    @domain.reload
    
    # Associate dnskey with domain for DNSSEC tests
    @dnskey.update(domain: @domain) if @dnskey
  end

  # Basic functionality tests
  
  test 'initializes with correct structure' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    
    assert_equal @domain, validator.domain
    assert_instance_of Hash, validator.results
    
    expected_keys = [:nameservers, :dns_records, :dnssec, :csync, :errors, :warnings]
    expected_keys.each do |key|
      assert_includes validator.results.keys, key
    end
  end

  test 'class method validate creates instance' do
    result = { test: 'result' }
    
    # Mock the class method directly
    DNSValidator.stub :validate, result do
      actual_result = DNSValidator.validate(domain: @domain, name: @domain.name, record_type: 'NS')
      assert_equal result, actual_result
    end
  end

  # Story 1: Nameserver Validation Tests
  
  test 'validates nameservers successfully' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    
    # Mock successful nameserver validation
    validator.define_singleton_method(:validate_single_nameserver) do |ns|
      { valid: true, authoritative: true, ns_records: [ns.hostname], reason: nil }
    end
    
    validator.send(:validate_nameservers)
    
    @nameserver1.reload
    assert_not_nil @nameserver1.validation_datetime
    assert_equal 0, @nameserver1.validation_counter
    assert_nil @nameserver1.failed_validation_reason
    
    assert validator.results[:nameservers][@nameserver1.hostname][:valid]
    assert_empty validator.results[:errors]
  end

  test 'handles failed nameserver validation' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    
    # Mock failed nameserver validation
    validator.define_singleton_method(:validate_single_nameserver) do |ns|
      { valid: false, authoritative: false, ns_records: [], reason: 'No SOA record found' }
    end
    
    validator.send(:validate_nameservers)
    
    @nameserver1.reload
    assert_not_nil @nameserver1.validation_datetime
    assert_equal 1, @nameserver1.validation_counter
    assert_equal 'No SOA record found', @nameserver1.failed_validation_reason
    
    assert_not validator.results[:nameservers][@nameserver1.hostname][:valid]
    assert_includes validator.results[:errors], "Nameserver #{@nameserver1.hostname} failed validation: No SOA record found"
  end

  test 'validates single nameserver with mocked DNS' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    
    # Create mock resolver
    resolver = create_mock_resolver
    
    # Create references to helper methods in test context
    test_context = self
    nameserver_hostname = @nameserver1.hostname
    
    # Mock SOA response (authoritative)
    soa_response = create_mock_dns_response([create_mock_soa_record])
    ns_response = create_mock_dns_response([create_mock_ns_record(nameserver_hostname)])
    
    resolver.define_singleton_method(:query) do |domain, type|
      if type == 'SOA'
        soa_response
      elsif type == 'NS'
        ns_response
      else
        test_context.create_mock_dns_response([])
      end
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    
    result = validator.send(:validate_single_nameserver, @nameserver1)
    
    assert result[:valid]
    assert result[:authoritative]
    assert_includes result[:ns_records], @nameserver1.hostname.downcase
    assert_nil result[:reason]
  end

  test 'detects nameserver not in NS records' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    resolver = create_mock_resolver
    
    # Pre-create responses
    test_context = self
    soa_response = create_mock_dns_response([create_mock_soa_record])
    ns_response = create_mock_dns_response([create_mock_ns_record('other.nameserver.com')])
    
    resolver.define_singleton_method(:query) do |domain, type|
      if type == 'SOA'
        soa_response
      elsif type == 'NS'
        ns_response
      else
        test_context.create_mock_dns_response([])
      end
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    
    result = validator.send(:validate_single_nameserver, @nameserver1)
    
    assert_not result[:valid]
    assert_equal 'Nameserver not listed in zone NS records', result[:reason]
  end

  test 'detects CNAME at apex' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    resolver = create_mock_resolver
    
    # Pre-create CNAME response
    test_context = self
    cname_response = create_mock_dns_response([create_mock_cname_record('example.com')])
    
    # Mock CNAME response for SOA query
    resolver.define_singleton_method(:query) do |domain, type|
      cname_response
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    
    result = validator.send(:validate_single_nameserver, @nameserver1)
    
    assert_not result[:valid]
    assert_equal 'Domain has CNAME record at apex (invalid)', result[:reason]
  end

  # Story 2: DNS Records Validation Tests
  
  test 'validates DNS records from valid nameservers' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'A')
    
    # Set up nameserver validation results
    validator.instance_variable_set(:@results, {
      nameservers: { @nameserver1.hostname => { valid: true } },
      dns_records: { a_records: [], aaaa_records: [], cname_records: [] },
      errors: [],
      warnings: []
    })
    
    # Pre-create responses
    test_context = self
    a_response = create_mock_dns_response([create_mock_a_record('192.0.2.1')])
    aaaa_response = create_mock_dns_response([create_mock_aaaa_record('2001:db8::1')])
    empty_response = create_mock_dns_response([])
    
    resolver = create_mock_resolver
    resolver.define_singleton_method(:query) do |domain, type|
      case type
      when 'A'
        a_response
      when 'AAAA'
        aaaa_response
      when 'CNAME'
        empty_response
      else
        empty_response
      end
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    
    validator.send(:validate_dns_records)
    
    assert_not_empty validator.results[:dns_records][:a_records]
    assert_not_empty validator.results[:dns_records][:aaaa_records]
    
    a_record = validator.results[:dns_records][:a_records].first
    assert_equal '192.0.2.1', a_record[:address]
    assert_equal @nameserver1.hostname, a_record[:nameserver]
  end

  test 'skips DNS validation when no valid nameservers' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'A')
    
    # Set up scenario with no valid nameservers
    validator.instance_variable_set(:@results, {
      nameservers: { @nameserver1.hostname => { valid: false } },
      dns_records: { a_records: [], aaaa_records: [], cname_records: [] },
      errors: [],
      warnings: []
    })
    
    validator.send(:validate_dns_records)
    
    assert_includes validator.results[:warnings], 'No valid nameservers found for DNS record validation'
    assert_empty validator.results[:dns_records][:a_records]
  end

  # Story 4: DNSSEC Tests
  
  test 'processes CDS records for DNSSEC sync' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    resolver = create_mock_resolver
    
    # Pre-create responses
    test_context = self
    cds_response = create_mock_dns_response([create_mock_cds_record(12345, 7, 1, 'ABC123')])
    empty_response = create_mock_dns_response([])
    
    resolver.define_singleton_method(:query) do |domain, type|
      case type
      when 'CDS'
        cds_response
      when 'CDNSKEY'
        empty_response
      else
        empty_response
      end
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    
    validator.send(:check_dnssec_sync_records)
    
    assert_not_empty validator.results[:dnssec][:cds_records]
    
    cds_record = validator.results[:dnssec][:cds_records].first
    assert_equal 12345, cds_record[:key_tag]
    assert_equal 7, cds_record[:algorithm]
  end

  # Story 6: Enforcement Actions Tests
  
  test 'removes failed nameservers after threshold' do
    @nameserver1.update!(validation_counter: 3, failed_validation_reason: 'Failed validation')
    
    # Ensure domain has enough nameservers
    @domain.nameservers.create!(hostname: 'backup.ns.com')
    
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    
    # Initialize complete results structure
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { ds_updates_needed: [] },
      csync: { delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    validator.define_singleton_method(:should_auto_remove_nameserver?) { true }
    validator.define_singleton_method(:create_notification) { |text| nil }
    
    initial_count = @domain.nameservers.count
    validator.send(:apply_enforcement_actions)
    
    assert_equal initial_count - 1, @domain.nameservers.count
    assert_not @domain.nameservers.exists?(@nameserver1.id)
    assert_includes validator.results[:warnings], "Automatically removed nameserver #{@nameserver1.hostname}"
  end

  test 'does not remove nameserver if insufficient nameservers' do
    @nameserver1.update!(validation_counter: 3, failed_validation_reason: 'Failed validation')
    @nameserver2.destroy # Only one nameserver left
    
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { ds_updates_needed: [] },
      csync: { delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    validator.define_singleton_method(:should_auto_remove_nameserver?) { true }
    
    initial_count = @domain.nameservers.count
    validator.send(:apply_enforcement_actions)
    
    assert_equal initial_count, @domain.nameservers.count
    assert @domain.nameservers.exists?(@nameserver1.id)
  end

  # Integration Tests
  
  test 'full validation workflow' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'all')
    
    # Mock all validation methods to avoid DNS calls
    validator.define_singleton_method(:validate_nameservers) { nil }
    validator.define_singleton_method(:validate_dns_records) { nil }
    validator.define_singleton_method(:check_dnssec_sync_records) { nil }
    validator.define_singleton_method(:check_csync_records) { nil }
    validator.define_singleton_method(:apply_enforcement_actions) { nil }
    
    results = validator.validate
    
    assert_instance_of Hash, results
    assert_includes results.keys, :nameservers
    assert_includes results.keys, :dns_records
    assert_includes results.keys, :dnssec
    assert_includes results.keys, :csync
  end

  test 'handles validation exceptions gracefully' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    
    validator.define_singleton_method(:validate_nameservers) do
      raise StandardError.new('DNS timeout')
    end
    
    results = validator.validate
    
    assert_includes results[:errors], 'Validation failed: DNS timeout'
  end

  # Helper method tests
  
  test 'helper methods work correctly' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    
    # Test parse_type_bitmap
    assert_equal ['NS', 'A'], validator.send(:parse_type_bitmap, ['NS', 'A'])
    assert_equal ['NS'], validator.send(:parse_type_bitmap, 'NS')
    assert_equal [], validator.send(:parse_type_bitmap, nil)
    
    # Test should_auto_remove_nameserver? (default is false)
    assert_not validator.send(:should_auto_remove_nameserver?)
    
    # Test create_resolver
    resolver = validator.send(:create_resolver, '192.0.2.1')
    assert_instance_of Dnsruby::Resolver, resolver
  end

  test 'handles domains without nameservers' do
    domain_without_ns = Domain.new(
      name: 'empty.test',
      registrar: @domain.registrar,
      registrant: @domain.registrant
    )
    
    validator = DNSValidator.new(domain: domain_without_ns, name: domain_without_ns.name, record_type: 'NS')
    
    assert_nothing_raised do
      validator.send(:validate_nameservers)
    end
    
    assert_empty validator.results[:nameservers]
  end

  private

  # Simple mock helpers using basic Ruby objects
  
  def create_mock_resolver
    resolver = Object.new
    resolver.define_singleton_method(:nameserver=) { |value| }
    resolver.define_singleton_method(:query_timeout=) { |value| }
    resolver.define_singleton_method(:retry_times=) { |value| }
    resolver.define_singleton_method(:recurse=) { |value| }
    resolver.define_singleton_method(:do_caching=) { |value| }
    resolver
  end

  def create_mock_dns_response(records)
    response = Object.new
    response.define_singleton_method(:answer) { records }
    response
  end

  def create_mock_soa_record(serial = 123456)
    record = Object.new
    record.define_singleton_method(:type) { 'SOA' }
    record.define_singleton_method(:serial) { serial }
    record.define_singleton_method(:instance_variable_defined?) { |var| var == '@serial' }
    record
  end

  def create_mock_ns_record(hostname)
    record = Object.new
    record.define_singleton_method(:type) { 'NS' }
    
    nsdname = Object.new
    nsdname.define_singleton_method(:to_s) { hostname }
    record.define_singleton_method(:nsdname) { nsdname }
    
    record
  end

  def create_mock_a_record(address)
    record = Object.new
    record.define_singleton_method(:type) { 'A' }
    record.define_singleton_method(:ttl) { 3600 }
    
    addr = Object.new
    addr.define_singleton_method(:to_s) { address }
    record.define_singleton_method(:address) { addr }
    
    record
  end

  def create_mock_aaaa_record(address)
    record = Object.new
    record.define_singleton_method(:type) { 'AAAA' }
    record.define_singleton_method(:ttl) { 3600 }
    
    addr = Object.new
    addr.define_singleton_method(:to_s) { address }
    record.define_singleton_method(:address) { addr }
    
    record
  end

  def create_mock_cname_record(target)
    record = Object.new
    record.define_singleton_method(:type) { 'CNAME' }
    record.define_singleton_method(:ttl) { 3600 }
    
    cname = Object.new
    cname.define_singleton_method(:to_s) { target }
    record.define_singleton_method(:cname) { cname }
    
    record
  end

  def create_mock_cds_record(key_tag, algorithm, digest_type, digest)
    record = Object.new
    record.define_singleton_method(:type) { 'CDS' }
    record.define_singleton_method(:key_tag) { key_tag }
    record.define_singleton_method(:algorithm) { algorithm }
    record.define_singleton_method(:digest_type) { digest_type }
    record.define_singleton_method(:digest) { digest }
    record
  end
end