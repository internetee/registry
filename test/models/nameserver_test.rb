require 'test_helper'

class NameserverTest < ActiveSupport::TestCase
  def setup
    @nameserver = nameservers(:shop_ns1)
  end

  def test_valid
    assert @nameserver.valid?
  end

  def test_invalid_without_domain
    @nameserver.domain = nil
    assert @nameserver.invalid?
  end

  def test_invalid_without_hostname
    @nameserver.hostname = ''
    assert @nameserver.invalid?
  end

  def test_hostname_format_validation
    @nameserver.hostname = 'foo_bar'
    assert @nameserver.invalid?

    @nameserver.hostname = 'foo.bar'
    assert @nameserver.valid?

    @nameserver.hostname = 'äöüõšž.ÄÖÜÕŠŽ.umlauts'
    assert @nameserver.valid?
  end

  def test_hostnames
    assert_equal %w[ns1.bestnames.test
      ns2.bestnames.test
      ns1.bestnames.test
      ns1.bestnames.test], Nameserver.hostnames
  end

  def test_normalizes_hostname
    @nameserver.hostname = ' ns1.bestnameS.test.'
    @nameserver.validate
    assert_equal 'ns1.bestnames.test', @nameserver.hostname
  end

  def test_normalizes_ipv4
    @nameserver.ipv4 = [' 192.0.2.1']
    @nameserver.validate
    assert_equal ['192.0.2.1'], @nameserver.ipv4
  end

  def test_normalizes_ipv6
    @nameserver.ipv6 = [' 2001:db8::1']
    @nameserver.validate
    assert_equal ['2001:DB8::1'], @nameserver.ipv6
  end
end
