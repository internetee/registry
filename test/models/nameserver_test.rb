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
    @nameserver.validate
    assert @nameserver.invalid?
  end

  def test_invalid_without_hostname
    @nameserver.hostname = nil
    @nameserver.validate
    assert @nameserver.invalid?
  end
end
