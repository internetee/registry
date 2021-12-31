require 'test_helper'

class ValidateDnssecTest < ActiveSupport::TestCase
  setup do
    @dnskey = dnskeys(:one)
    @domain = domains(:shop)

    @result_container = [{
                           basic: {
                             flags: @dnskey.flags.to_s,
                             algorithm: @dnskey.alg.to_s,
                             protocol: @dnskey.protocol.to_s,
                           },
                           public_key: @dnskey.public_key.to_s
                         }]

    Spy.on_instance_method(ValidateDnssec, :validation_dns_key_error).and_return(false)
  end

  def test_should_return_true_if_dnssec_data_are_matches
    Spy.on_instance_method(ValidateDnssec, :get_dnskey_records_from_subzone).and_return(@result_container)
    match_params = build_params(@dnskey.flags)
    validate_result = ValidateDnssec.validate_dnssec(params: match_params, domain: @domain)

    assert validate_result
  end

  def test_should_return_false_if_dnssec_data_does_not_matcher
    Spy.on_instance_method(ValidateDnssec, :get_dnskey_records_from_subzone).and_return(@result_container)
    match_params = build_params(256)
    validate_result = ValidateDnssec.validate_dnssec(params: match_params, domain: @domain)

    refute validate_result
  end

  def build_params(flag)
    {
      action: "add",
      domain: @domain,
      dns_keys: [{
                   flags: flag,
                   alg: @dnskey.alg,
                   protocol: @dnskey.protocol,
                   public_key: @dnskey.public_key
                 }]
    }
  end
end
