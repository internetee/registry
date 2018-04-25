require 'test_helper'

class WhoisRecordTest < ActiveSupport::TestCase
  def setup
    super

    @domain = domains(:shop)
    @record = WhoisRecord.new(domain: @domain)
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
    expected_disclaimer_first_line = begin
      "Search results may not be used for commercial, advertising, recompilation,"
    end
    expected_disclaimer_second_line = begin
      "repackaging, redistribution, reuse, obscuring or other similar activities"
    end
    @record.populate

    assert_match(expected_disclaimer_first_line, @record.body)
    assert_match(expected_disclaimer_second_line, @record.body)
  end
end
