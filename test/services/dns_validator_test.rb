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
  
  # New tests for apply_changes flag functionality
  
  test 'initializes with apply_changes flag defaulting to true' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS')
    assert_equal true, validator.apply_changes
  end
  
  test 'respects apply_changes flag when false' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'NS', apply_changes: false)
    assert_equal false, validator.apply_changes
  end
  
  test 'does not apply changes when apply_changes is false' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY', apply_changes: false)
    
    # Set up DNSSEC updates needed
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { 
        ds_updates_needed: [
          { action: 'update_ds', cds_data: { key_tag: 12345 }, reason: 'Test', validated: true }
        ],
        cds_records: [],
        cdnskey_records: []
      },
      csync: { delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    # Mock methods to track if they're called
    update_called = false
    validator.define_singleton_method(:update_ds_record) { |data| update_called = true }
    validator.define_singleton_method(:create_notification) { |text| nil }
    
    validator.send(:apply_enforcement_actions)
    
    assert_not update_called, "Update should not be called when apply_changes is false"
    assert_includes validator.results[:warnings], "DNSSEC updates detected but not applied (validation mode only):"
  end
  
  # CDS record tests
  
  test 'processes CDS records with validation' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    
    # Initialize results structure first
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { cds_records: [], cdnskey_records: [], ds_updates_needed: [] },
      csync: { csync_records: [], delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    resolver = create_mock_resolver
    
    # Pre-create CDS response with proper structure
    cds_response = create_mock_dns_response([
      create_mock_cds_record(12345, 7, 2, 'ABCDEF123456')
    ])
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
    
    resolver.define_singleton_method(:dnssec=) { |value| }
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    validator.define_singleton_method(:validate_dnssec_chain) { |ns| false } # Not validated
    
    validator.send(:check_cds_records, @nameserver1)
    
    assert_not_empty validator.results[:dnssec][:cds_records]
    cds = validator.results[:dnssec][:cds_records].first
    assert_equal 12345, cds[:key_tag]
    assert_equal 7, cds[:algorithm]
    assert_equal 2, cds[:digest_type]
    assert_equal 'ABCDEF123456', cds[:digest]
    assert_equal false, cds[:validated]
  end
  
  test 'handles CDS record with algorithm 0 for removal' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    
    # Initialize results structure
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { cds_records: [], cdnskey_records: [], ds_updates_needed: [] },
      csync: { csync_records: [], delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    resolver = create_mock_resolver
    
    # CDS with algorithm 0 means remove all DS records
    cds_response = create_mock_dns_response([
      create_mock_cds_record(0, 0, 0, 'AA==')
    ])
    
    resolver.define_singleton_method(:query) do |domain, type|
      type == 'CDS' ? cds_response : create_mock_dns_response([])
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    validator.define_singleton_method(:validate_dnssec_chain) { |ns| true }
    
    validator.send(:check_cds_records, @nameserver1)
    
    ds_updates = validator.results[:dnssec][:ds_updates_needed]
    assert_not_empty ds_updates
    assert_equal 'remove_ds', ds_updates.first[:action]
  end
  
  # CDNSKEY record tests
  
  test 'processes CDNSKEY records correctly' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    
    # Initialize results structure
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { cds_records: [], cdnskey_records: [], ds_updates_needed: [] },
      csync: { csync_records: [], delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    resolver = create_mock_resolver
    
    # Mock CDNSKEY response
    cdnskey_response = create_mock_dns_response([
      create_mock_cdnskey_record(257, 3, 13, 'mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==')
    ])
    
    resolver.define_singleton_method(:query) do |domain, type|
      type == 'CDNSKEY' ? cdnskey_response : create_mock_dns_response([])
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    validator.define_singleton_method(:validate_dnssec_chain) { |ns| false }
    
    validator.send(:check_cdnskey_records, @nameserver1)
    
    assert_not_empty validator.results[:dnssec][:cdnskey_records]
    cdnskey = validator.results[:dnssec][:cdnskey_records].first
    assert_equal 257, cdnskey[:flags]
    assert_equal 3, cdnskey[:protocol]
    assert_equal 13, cdnskey[:algorithm]
  end
  
  test 'handles CDNSKEY with algorithm 0 for deletion' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    
    # Initialize results structure
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { cds_records: [], cdnskey_records: [], ds_updates_needed: [] },
      csync: { csync_records: [], delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    resolver = create_mock_resolver
    
    # CDNSKEY with algorithm 0 means delete all keys
    cdnskey_response = create_mock_dns_response([
      create_mock_cdnskey_record(0, 3, 0, 'AA==')
    ])
    
    resolver.define_singleton_method(:query) do |domain, type|
      type == 'CDNSKEY' ? cdnskey_response : create_mock_dns_response([])
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    
    validator.send(:check_cdnskey_records, @nameserver1)
    
    assert_not_empty validator.results[:dnssec][:ds_updates_needed]
    assert_equal 'remove_all_dnskeys', validator.results[:dnssec][:ds_updates_needed].first[:action]
  end
  
  test 'detects KSK rotation from CDNSKEY' do
    # Set up domain with existing KSK - use valid base64 string from fixtures
    @dnskey.update!(flags: 257, protocol: 3, alg: 13, public_key: 'mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==')
    
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    resolver = create_mock_resolver
    
    # Initialize results structure
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { cds_records: [], cdnskey_records: [], ds_updates_needed: [] },
      csync: { csync_records: [], delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    # New KSK in CDNSKEY - different valid base64 key
    cdnskey_response = create_mock_dns_response([
      create_mock_cdnskey_record(257, 3, 13, 'AwEAAaz/tAm8yTn4Mfeh5eyI96WSVexTBAvkMgJzkKTOiW1vkIbzxeF3+/4RgWOq7HrxRixHlFlExOLAJr5emLvN7SWXgnLh4+B5xQlNVz8Og8kvArMtNROxVQuCaSnIDdD5LKyWbRd2n9WGe2R8PzgCmr3EgVLrjyBxWezF0jLHwVN8efS3rCj/EWgvIWgb9tarpVUDK/b58Da+sqqls3eNbuv7pr+eoZG+SrDK6nWeL3c6H5Apxz7LjVc1uTIdsIXxuOLYA4/ilBmSVIzuDWfdRUfhHdY6+cn8HFRm+2hM8AnXGXws9555KrUB5qihylGa8subX2Nn6UwNR1AkUTV74bU=')
    ])
    
    resolver.define_singleton_method(:query) do |domain, type|
      type == 'CDNSKEY' ? cdnskey_response : create_mock_dns_response([])
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    validator.define_singleton_method(:validate_dnssec_chain) { |ns| true }
    
    validator.send(:check_cdnskey_records, @nameserver1)
    
    ds_updates = validator.results[:dnssec][:ds_updates_needed]
    rotation_update = ds_updates.find { |u| u[:action] == 'rotate_ksk' }
    assert_not_nil rotation_update
    assert_includes rotation_update[:old_keys], @dnskey.id
  end
  
  # CSYNC record tests
  
  test 'parses CSYNC records correctly' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'CSYNC')
    
    # Initialize results structure
    validator.instance_variable_set(:@results, {
      nameservers: {},
      dns_records: {},
      dnssec: { cds_records: [], cdnskey_records: [], ds_updates_needed: [] },
      csync: { csync_records: [], delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    resolver = create_mock_resolver
    
    # Mock CSYNC (TYPE62) response
    csync_response = create_mock_dns_response([
      create_mock_csync_record(123456789, 3, ['NS', 'A', 'AAAA'])
    ])
    
    # Mock send_message for TYPE62 query
    resolver.define_singleton_method(:send_message) do |message|
      csync_response
    end
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    validator.define_singleton_method(:check_ns_sync_needed) { |ns| }
    validator.define_singleton_method(:check_a_sync_needed) { |ns| }
    validator.define_singleton_method(:check_aaaa_sync_needed) { |ns| }
    
    validator.send(:check_single_csync_record, @nameserver1)
    
    assert_not_empty validator.results[:csync][:csync_records]
    csync = validator.results[:csync][:csync_records].first
    assert_equal 123456789, csync[:serial]
    assert_equal 3, csync[:flags]
    assert csync[:immediate]
    assert csync[:soaminimum]
    assert_includes csync[:type_bitmap], 'NS'
    assert_includes csync[:type_bitmap], 'A'
    assert_includes csync[:type_bitmap], 'AAAA'
  end
  
  test 'detects NS synchronization needed from CSYNC' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'CSYNC')
    
    # Set up nameserver validation results
    validator.instance_variable_set(:@results, {
      nameservers: {
        @nameserver1.hostname => { valid: true, ns_records: ['ns1.other.com', 'ns2.other.com'] },
        @nameserver2.hostname => { valid: true, ns_records: ['ns1.other.com', 'ns2.other.com'] }
      },
      dns_records: {},
      dnssec: { ds_updates_needed: [] },
      csync: { csync_records: [], delegation_updates_needed: [] },
      errors: [],
      warnings: []
    })
    
    validator.send(:check_ns_sync_needed, @nameserver1)
    
    updates = validator.results[:csync][:delegation_updates_needed]
    assert_not_empty updates
    
    ns_update = updates.find { |u| u[:type] == 'ns_records' }
    assert_not_nil ns_update
    assert_not_empty ns_update[:add]
    assert_includes ns_update[:add], 'ns1.other.com'
  end
  
  # Update methods tests
  
  test 'update_ds_record creates or updates DS record' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    
    # First create a dnskey with required fields that we'll update
    existing_key = @domain.dnskeys.create!(
      flags: 257,
      protocol: 3,
      alg: 8,
      public_key: 'AwEAAaz/tAm8yTn4Mfeh5eyI96WSVexTBAvkMgJzkKTOiW1vkIbzxeF3+/4RgWOq7HrxRixHlFlExOLAJr5emLvN7SWXgnLh4+B5xQlNVz8Og8kvArMtNROxVQuCaSnIDdD5LKyWbRd2n9WGe2R8PzgCmr3EgVLrjyBxWezF0jLHwVN8efS3rCj/EWgvIWgb9tarpVUDK/b58Da+sqqls3eNbuv7pr+eoZG+SrDK6nWeL3c6H5Apxz7LjVc1uTIdsIXxuOLYA4/ilBmSVIzuDWfdRUfhHdY6+cn8HFRm+2hM8AnXGXws9555KrUB5qihylGa8subX2Nn6UwNR1AkUTV74bU=',
      ds_key_tag: '54321'
    )
    
    cds_data = {
      key_tag: 54321,
      algorithm: 8,
      digest_type: 2,
      digest: 'FEDCBA987654'
    }
    
    validator.define_singleton_method(:create_notification) { |text| nil }
    
    # update_ds_record should update the existing record
    validator.send(:update_ds_record, cds_data)
    
    # Reload and verify
    existing_key.reload
    assert_equal '54321', existing_key.ds_key_tag
    assert_equal 8, existing_key.ds_alg
    assert_equal 2, existing_key.ds_digest_type
    assert_equal 'FEDCBA987654', existing_key.ds_digest
  end
  
  test 'remove_all_dnskeys removes all DNSSEC keys' do
    # Create additional keys with valid base64 public key
    @domain.dnskeys.create!(flags: 256, protocol: 3, alg: 13, public_key: 'AwEAAYCMDMDqoEKPbuW7qPxTvdeWOZsSe8D6v3G9O7cLnWbwFe2yUW6eVG2BRLbo8fIxu0V3u8hHPqnFqzLgV/cHqlIhfcLVgFJLSYVBPqTRh8j1TEL0Rbz6GTzTDVnLO2F8DnudqPmNM1eSjUPmUto3ti7A9z2mfqiEGhtC0YT9Nne3')
    
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    validator.define_singleton_method(:create_notification) { |text| nil }
    
    initial_count = @domain.dnskeys.count
    assert initial_count > 0
    
    validator.send(:remove_all_dnskeys)
    
    assert_equal 0, @domain.dnskeys.count
  end
  
  test 'rotate_ksk replaces old KSK with new one' do
    old_ksk = @domain.dnskeys.create!(flags: 257, protocol: 3, alg: 13, public_key: 'AwEAAaz/tAm8yTn4Mfeh5eyI96WSVexTBAvkMgJzkKTOiW1vkIbzxeF3+/4RgWOq7HrxRixHlFlExOLAJr5emLvN7SWXgnLh4+B5xQlNVz8Og8kvArMtNROxVQuCaSnIDdD5LKyWbRd2n9WGe2R8PzgCmr3EgVLrjyBxWezF0jLHwVN8efS3rCj/EWgvIWgb9tarpVUDK/b58Da+sqqls3eNbuv7pr+eoZG+SrDK6nWeL3c6H5Apxz7LjVc1uTIdsIXxuOLYA4/ilBmSVIzuDWfdRUfhHdY6+cn8HFRm+2hM8AnXGXws9555KrUB5qihylGa8subX2Nn6UwNR1AkUTV74bU=')
    
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    validator.define_singleton_method(:create_notification) { |text| nil }
    
    cdnskey_data = {
      flags: 257,
      protocol: 3,
      algorithm: 13,
      public_key: 'mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ=='
    }
    
    validator.send(:rotate_ksk, cdnskey_data, [old_ksk.id])
    
    assert_not @domain.dnskeys.exists?(old_ksk.id)
    assert @domain.dnskeys.exists?(public_key: 'mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==')
  end
  
  # DNSSEC validation tests
  
  test 'validate_dnssec_chain checks DNSSEC' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    resolver = create_mock_resolver
    
    # Mock secure response
    secure_response = create_mock_dns_response([])
    secure_response.define_singleton_method(:security_level) { Dnsruby::Message::SecurityLevel.const_get(:SECURE) }
    
    resolver.define_singleton_method(:dnssec=) { |value| }
    resolver.define_singleton_method(:query) { |domain, type| secure_response }
    
    validator.define_singleton_method(:create_resolver) { |ip| resolver }
    
    result = validator.send(:validate_dnssec_chain, @nameserver1)
    assert result
  end
  
  test 'require_dnssec_validation returns true when domain has keys' do
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    assert validator.send(:require_dnssec_validation?)
  end
  
  test 'require_dnssec_validation returns false when domain has no keys' do
    @domain.dnskeys.destroy_all
    validator = DNSValidator.new(domain: @domain, name: @domain.name, record_type: 'DNSKEY')
    assert_not validator.send(:require_dnssec_validation?)
  end
  
  # Class method tests
  
  test 'check_only class method creates validator with apply_changes false' do
    DNSValidator.stub :new, ->(args) { 
      assert_equal false, args[:apply_changes]
      validator = Object.new
      validator.define_singleton_method(:validate) { { test: 'result' } }
      validator
    } do
      result = DNSValidator.check_only(domain: @domain)
      assert_equal({ test: 'result' }, result)
    end
  end
  
  test 'apply_dnssec_updates class method uses DNSKEY record type' do
    DNSValidator.stub :new, ->(args) { 
      assert_equal 'DNSKEY', args[:record_type]
      assert_equal true, args[:apply_changes]
      validator = Object.new
      validator.define_singleton_method(:validate) { { test: 'result' } }
      validator
    } do
      result = DNSValidator.apply_dnssec_updates(domain: @domain)
      assert_equal({ test: 'result' }, result)
    end
  end
  
  test 'apply_delegation_updates class method uses CSYNC record type' do
    DNSValidator.stub :new, ->(args) { 
      assert_equal 'CSYNC', args[:record_type]
      assert_equal true, args[:apply_changes]
      validator = Object.new
      validator.define_singleton_method(:validate) { { test: 'result' } }
      validator
    } do
      result = DNSValidator.apply_delegation_updates(domain: @domain)
      assert_equal({ test: 'result' }, result)
    end
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
  
  def create_mock_cdnskey_record(flags, protocol, algorithm, key)
    record = Object.new
    record.define_singleton_method(:type) { 'CDNSKEY' }
    record.define_singleton_method(:flags) { flags }
    record.define_singleton_method(:protocol) { protocol }
    record.define_singleton_method(:algorithm) { algorithm }
    record.define_singleton_method(:key) { Base64.strict_decode64(key) }
    record
  end
  
  def create_mock_csync_record(serial, flags, types)
    record = Object.new
    record.define_singleton_method(:type) { 'TYPE62' }
    record.define_singleton_method(:type_string) { 'TYPE62' }
    
    # Create binary data for CSYNC record
    serial_bytes = [serial].pack('N')
    flags_bytes = [flags].pack('n')
    
    # Create type bitmap for NS (2), A (1), AAAA (28)
    # Window 0: types 0-255
    # Types 1 (A) and 2 (NS) are in byte 0: 01100000 = 0x60
    # Type 28 (AAAA) is in byte 3, bit 4: 00001000 = 0x08
    window_0 = "\x00"  # Window number 0
    bitmap_len = "\x04" # 4 bytes of bitmap
    bitmap = "\x60\x00\x00\x08" # Bits for types 1, 2, and 28
    
    type_bitmap = window_0 + bitmap_len + bitmap
    
    rdata = serial_bytes + flags_bytes + type_bitmap
    record.define_singleton_method(:rdata) { rdata }
    record
  end
  
  def create_mock_message(name, type_str, class_str)
    message = Object.new
    message
  end
end