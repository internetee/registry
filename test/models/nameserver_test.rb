require 'test_helper'

class NameserverTest < ActiveSupport::TestCase
  def setup
    @nameserver = nameservers(:ns1)
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

  def test_hostnames
    assert_equal %w[ns1.bestnames.test ns2.bestnames.test], Nameserver.hostnames
  end
end
