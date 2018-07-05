require 'test_helper'

class ReplaceNameserversTest < ActiveSupport::TestCase
  def setup
    @registrar = registrars(:bestnames)
  end

  def test_replace_nameservers_in_bulk_returns_domain_names
    new_attributes = { hostname: 'ns-updated1.bestnames.test', ipv4: '192.0.3.1',
                       ipv6: '2001:db8::2' }
    result = @registrar.replace_nameservers('ns1.bestnames.test', new_attributes)

    assert_equal(["airport.test", "shop.test"], result)
  end

  def test_replace_nameservers_in_bulk_returns_empty_array_for_non_existent_base_nameserver
    new_attributes = { hostname: 'ns-updated1.bestnames.test', ipv4: '192.0.3.1',
                       ipv6: '2001:db8::2' }
    result = @registrar.replace_nameservers('ns3.bestnames.test', new_attributes)

    assert_equal([], result)
  end
end
