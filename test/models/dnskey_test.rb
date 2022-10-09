require 'test_helper'

class DnskeyTest < ActiveSupport::TestCase
    include EppErrors

  setup do
    @dnskey = 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8'
    @domain = domains(:shop)
  end

  def test_valid_dns_key
    dns = Dnskey.new
    dns.domain_id = @domain.id
    dns.flags = 257
    dns.protocol = 3
    dns.alg = 8
    dns.public_key = @dnskey

    assert dns.save
  end

  def test_invalid_algrorithm
    dns = Dnskey.new
    dns.alg = 666
    errors = dns.validate_algorithm.options[:values]
    assert_equal errors, "Valid algorithms are: #{Dnskey::ALGORITHMS.join(', ')}"
  end

  def test_invalid_protocol
    dns = Dnskey.new
    dns.protocol = 666
    errors = dns.validate_protocol.options[:values]
    assert_equal errors, 'Valid protocols are: 3'
  end

  def test_invalid_flags
    dns = Dnskey.new
    dns.flags = 666
    errors = dns.validate_flags.options[:values]
    assert_equal errors, 'Valid flags are: 0, 256, 257'
  end

  def test_ds_digest_type_one
    Setting.ds_digest_type = 1

    dns = Dnskey.new
    dns.domain_id = @domain.id
    dns.flags = 257
    dns.protocol = 3
    dns.alg = 8
    dns.public_key = @dnskey

    assert dns.save

    assert_equal dns.ds_digest_type, 1
    assert_equal dns.ds_digest, '640D173A44D9AF2856FBE282EE64CE11A76DBB84'
  end

  def test_remove_public_key_whitespaces
    dnskey = "  AwEAAddt 2AkLfYGKgiEZ    B5SmIF8Evr jxNMH6HtxWEA4RJ9Ao6LCWheg8 \n "

    dns = Dnskey.new
    dns.domain_id = @domain.id
    dns.flags = 257
    dns.protocol = 3
    dns.alg = 8
    dns.public_key = dnskey
    dns.save

    assert_equal dns.public_key, @dnskey
  end
end
