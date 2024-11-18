require 'test_helper'

class BusinessRegistry::DomainAvailabilityCheckerServiceTest < ActiveSupport::TestCase
  test "should filter out reserved domains" do
    ReservedDomain.create(name: "reserved-domain.test")
    domains = ["available.test", "reserved-domain.test", "another.test"]
    available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domains)
    assert_equal ["available.test", "another.test"], available
  end

  test "should return all domains if none are reserved" do
    domains = ["available.test", "another.test"]
    available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domains)
    assert_equal domains, available
  end

  test "should return empty array if all domains are reserved" do
    ReservedDomain.create(name: "reserved-domain1.test")
    ReservedDomain.create(name: "reserved-domain2.test")
    domains = ["reserved-domain1.test", "reserved-domain2.test"]
    available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domains)
    assert_empty available
  end
end
