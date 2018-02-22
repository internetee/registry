require 'test_helper'

class NameserverGlueRecordTest < ActiveSupport::TestCase
  def setup
    @nameserver = nameservers(:ns1)
  end

  def test_invalid_without_ip_if_glue_record_is_required
    @nameserver.hostname = 'ns1.shop.test'
    @nameserver.ipv4 = @nameserver.ipv6 = ''
    assert @nameserver.invalid?
    assert @nameserver.errors.added?(:base, :ip_required)
  end

  def test_valid_with_ip_if_glue_record_is_required
    @nameserver.hostname = 'ns1.shop.test'
    @nameserver.ipv4 = ['192.0.2.1']
    @nameserver.ipv6 = ''
    assert @nameserver.valid?
  end

  def test_valid_without_ip_if_glue_record_is_not_required
    @nameserver.ipv4 = @nameserver.ipv6 = ''
    assert @nameserver.valid?
  end
end
