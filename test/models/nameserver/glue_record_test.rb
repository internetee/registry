require 'test_helper'

class NameserverGlueRecordTest < ActiveSupport::TestCase
  setup do
    @nameserver = nameservers(:shop_ns1)
  end

  def test_invalid_when_glue_record_is_required_and_no_ip_is_provided
    domain = Domain.new(name: 'shop.test')
    nameserver = Nameserver.new(domain: domain, hostname: 'ns1.shop.test')

    assert nameserver.invalid?
    assert_includes nameserver.errors.full_messages, 'Either IPv4 or IPv6 is required' \
    ' for glue record generation'
  end

  def test_valid_when_glue_record_is_required_and_ipv4_is_provided
    domain = Domain.new(name: 'shop.test')
    nameserver = Nameserver.new(domain: domain, hostname: 'ns1.shop.test')
    nameserver.ipv4 = ['192.0.2.1']

    assert nameserver.valid?
  end

  def test_valid_when_glue_record_is_required_and_ipv6_is_provided
    domain = Domain.new(name: 'shop.test')
    nameserver = Nameserver.new(domain: domain, hostname: 'ns1.shop.test')
    nameserver.ipv6 = ['2001:db8::1']

    assert nameserver.valid?
  end

  def test_valid_when_glue_record_is_not_required_and_no_ip_is_provided
    domain = Domain.new(name: 'shop.test')
    nameserver = Nameserver.new(domain: domain, hostname: 'ns1.registrar.test')

    assert nameserver.valid?
  end

  def test_valid_when_glue_record_is_not_required_and_no_ip_is_provided_substring_match
    domain = Domain.new(name: 'le.test')
    nameserver = Nameserver.new(domain: domain, hostname: 'ns1.shop.test')

    assert nameserver.valid?
  end
end
