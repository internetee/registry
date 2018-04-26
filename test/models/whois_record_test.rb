require 'test_helper'

class WhoisRecordTest < ActiveSupport::TestCase
  def setup
    super

    @domain = domains(:shop)
    @record = WhoisRecord.new(domain: @domain)
    @record.populate
  end

  def test_generated_json_has_expected_values
    expected_disclaimer_text = <<-TEXT.squish
    Search results may not be used for commercial, advertising, recompilation,
    repackaging, redistribution, reuse, obscuring or other similar activities.
    TEXT

    expected_partial_hash = {
      disclaimer: expected_disclaimer_text,
      name: 'shop.test',
      registrant: 'John',
      registrant_kind: 'priv',
      email: 'john@inbox.test',
      expire: '2010-07-05',
      nameservers: ['ns1.bestnames.test', 'ns2.bestnames.test'],
      registrar_address: 'Main Street, New York, New York, 12345',
      dnssec_keys: [],
    }

    expected_partial_hash.each do |key, value|
      assert_equal(value, @record.generated_json[key])
    end
  end

  def test_generated_body_has_justified_disclaimer
    expected_disclaimer = begin
      'Search results may not be used for commercial, advertising, recompilation,\n' \
      'repackaging, redistribution, reuse, obscuring or other similar activities.'
    end
    expected_technical_contact = begin
      'Technical contact:\n' \
      'name:       Not Disclosed - Visit www.internet.ee for webbased WHOIS\n' \
      'email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n' \
      'changed:    Not Disclosed - Visit www.internet.ee for webbased WHOIS'
    end

    regexp_contact = Regexp.new(expected_technical_contact, Regexp::MULTILINE)
    regexp_disclaimer = Regexp.new(expected_disclaimer, Regexp::MULTILINE)

    assert_match(regexp_disclaimer,        @record.body)
    assert_match(regexp_contact,           @record.body)
  end

  def test_whois_record_has_no_disclaimer_if_Setting_is_blank
    Setting.stubs(:registry_whois_disclaimer, '') do
      refute(@record.json['disclaimer'])
      refute_match(/Search results may not be used for commercial/, @record.body)
    end
  end
end
