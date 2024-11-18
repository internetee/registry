require 'test_helper'

class BusinessRegistry::DomainAvailabilityCheckerServiceTest < ActiveSupport::TestCase
  def setup
    ReservedDomain.delete_all
    # Store original method
    @original_filter_available = BusinessRegistry::DomainAvailabilityCheckerService.method(:filter_available)
  end

  def teardown
    # Restore original method
    if @original_filter_available
      BusinessRegistry::DomainAvailabilityCheckerService.define_singleton_method(:filter_available, @original_filter_available)
    end
  end

  test "should filter out reserved domains" do
    ReservedDomain.create!(name: "reserved-domain.test")
    domains = ["available.test", "reserved-domain.test", "another.test"]
    
    Epp::Domain.stub :check_availability, [
      {name: "available.test", avail: 1},
      {name: "reserved-domain.test", avail: 1},
      {name: "another.test", avail: 1}
    ] do
      available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domains)
      assert_equal ["available.test", "another.test"], available
    end
  end

  test "should return all domains if none are reserved" do
    domains = ["available.test", "another.test"]
    available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domains)
    assert_equal domains, available
  end

  test "should return empty array if all domains are reserved" do
    domain_names = ["reserved-domain1.test", "reserved-domain2.test"]
    ReservedDomain.create!(name: domain_names.first)
    ReservedDomain.create!(name: domain_names.last)
    available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domain_names)
    assert_empty available
  end
end
