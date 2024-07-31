require 'test_helper'

class BusinessRegistry::DomainAvailabilityCheckerServiceTest < ActiveSupport::TestCase
  test "should filter out reserved domains" do
    ReservedDomain.create(name: "reserved.test")
    domains = ["available.test", "reserved.test", "another.test"]
    available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domains)
    assert_equal ["available.test", "another.test"], available
  end

  test "should return all domains if none are reserved" do
    domains = ["available.test", "another.test"]
    available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domains)
    assert_equal domains, available
  end

  test "should return empty array if all domains are reserved" do
    ReservedDomain.create(name: "reserved1.test")
    ReservedDomain.create(name: "reserved2.test")
    domains = ["reserved1.test", "reserved2.test"]
    available = BusinessRegistry::DomainAvailabilityCheckerService.filter_available(domains)
    assert_empty available
  end
end
