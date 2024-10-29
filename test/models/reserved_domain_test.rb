require 'test_helper'

class ReservedDomainTest < ActiveSupport::TestCase
  setup do
    @reserved_domain = reserved_domains(:one)
    
    # Mock the domain availability checker
    @original_filter_available = BusinessRegistry::DomainAvailabilityCheckerService.method(:filter_available)
    BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available) do |domains|
      domains # Return all domains as available for testing
    end
  end

  test "fixture is valid" do
    assert @reserved_domain.valid?
  end

  test "aliases registration_code to password" do
    reserved_domain = ReservedDomain.new(password: 'test-123')
    assert_equal 'test-123', reserved_domain.registration_code
  end

  test "should generate password if empty" do
    reserved_domain = ReservedDomain.new(name: 'test.test')
    assert_nil reserved_domain.password
    reserved_domain.save
    assert_not_nil reserved_domain.password
  end

  test "should not override existing password" do
    reserved_domain = ReservedDomain.new(name: 'test.test', password: 'existing-pw')
    reserved_domain.save
    assert_equal 'existing-pw', reserved_domain.password
  end

  test "should generate whois record on save" do
    assert_difference 'Whois::Record.count' do
      ReservedDomain.create(name: 'new-domain.test')
    end
  end

  test "should not generate whois record if domain exists" do
    existing_domain = domains(:shop)
    assert_no_difference 'Whois::Record.count' do
      ReservedDomain.create(name: existing_domain.name)
    end
  end

  test "new_password_for should regenerate password" do
    old_password = @reserved_domain.password
    ReservedDomain.new_password_for(@reserved_domain.name)
    @reserved_domain.reload
    
    assert_not_equal old_password, @reserved_domain.password
  end

  test "reserve_domains_without_payment should handle maximum limit" do
    domain_names = (1..ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST + 1).map { |i| "domain#{i}.test" }
    
    result = ReservedDomain.reserve_domains_without_payment(domain_names)
    
    assert_not result.success
    assert_includes result.errors, "The maximum number of domain names per request is #{ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST}"
  end

  test "reserve_domains_without_payment should create domains" do
    domain_names = ["new1.test", "new2.test"]
    
    assert_difference 'ReservedDomain.count', 2 do
      result = ReservedDomain.reserve_domains_without_payment(domain_names)
      assert result.success
      assert_equal 2, result.reserved_domains.length
      assert result.reserved_domains.all? { |d| d.password.present? }
    end
  end

  test "reserve_domains_without_payment should filter unavailable domains" do
    # Mock the availability checker to return only one domain
    BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available) do |domains|
      [domains.first]
    end

    domain_names = ["available.test", "unavailable.test"]
    
    assert_difference 'ReservedDomain.count', 1 do
      result = ReservedDomain.reserve_domains_without_payment(domain_names)
      assert result.success
      assert_equal 1, result.reserved_domains.length
      assert_equal "available.test", result.reserved_domains.first.name
    end
  end
end
