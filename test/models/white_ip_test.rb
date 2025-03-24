require 'test_helper'

class WhiteIpTest < ActiveSupport::TestCase
  def test_either_ipv4_or_ipv6_is_required
    white_ip = valid_white_ip

    white_ip.ipv4 = ''
    white_ip.ipv6 = ''
    assert white_ip.invalid?
    assert_includes white_ip.errors.full_messages, 'IPv4 or IPv6 must be present'

    white_ip.ipv4 = valid_ipv4
    white_ip.ipv6 = ''
    assert white_ip.valid?

    white_ip.ipv4 = ''
    white_ip.ipv6 = valid_ipv6
    assert white_ip.valid?
  end

  def test_validates_ipv4_format
    white_ip = valid_white_ip

    white_ip.ipv4 = 'invalid'
    assert white_ip.invalid?

    white_ip.ipv4 = valid_ipv4
    assert white_ip.valid?
  end

  def test_validates_ipv6_format
    white_ip = valid_white_ip
    white_ip.ipv4 = nil

    white_ip.ipv6 = 'invalid'
    assert white_ip.invalid?

    white_ip.ipv6 = valid_ipv6
    assert white_ip.valid?
  end

  def test_validates_include_empty_ipv4
    white_ip = WhiteIp.new

    white_ip.ipv4 = nil
    white_ip.ipv6 = '001:0db8:85a3:0000:0000:8a2e:0370:7334'
    white_ip.registrar = registrars(:bestnames)

    assert_nothing_raised { white_ip.save }
    assert white_ip.valid?

    assert WhiteIp.include_ip?(white_ip.ipv6)
    assert_not WhiteIp.include_ip?('192.168.1.1')
  end

  def test_validates_ipv6_64_range
    white_ip = WhiteIp.new
    white_ip.registrar = registrars(:bestnames)
    white_ip.ipv6 = '2001:db8::/64'
    
    assert white_ip.valid?, 'IPv6 /64 range should be valid'
  end

  def test_validates_ipv6_single_address
    white_ip = WhiteIp.new
    white_ip.registrar = registrars(:bestnames)
    white_ip.ipv6 = '2001:db8::1'
    
    assert white_ip.valid?, 'Single IPv6 address should be valid'
  end

  def test_rejects_invalid_ipv6_range
    white_ip = WhiteIp.new
    white_ip.registrar = registrars(:bestnames)
    
    white_ip.ipv6 = '2001:db8::/48'
    assert white_ip.invalid?, 'IPv6 /48 range should be invalid'
    assert_includes white_ip.errors.full_messages, 'IPv6 address must be either a single address or a /64 range'

    white_ip.ipv6 = '2001:db8::/96'
    assert white_ip.invalid?, 'IPv6 /96 range should be invalid'
    assert_includes white_ip.errors.full_messages, 'IPv6 address must be either a single address or a /64 range'
  end

  private

  def valid_white_ip
    white_ips(:one)
  end

  def valid_ipv4
    '192.0.2.1'
  end

  def valid_ipv6
    '2001:db8::1'
  end
end
