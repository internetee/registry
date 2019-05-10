require 'test_helper'

class WhoisRecordTest < ActiveSupport::TestCase
  fixtures 'whois_records'

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
      expire: '2010-07-05',
      dnssec_keys: [],
    }

    expected_partial_hash.each do |key, value|
      assert_equal(value, @record.generated_json[key])
    end

    ['ns1.bestnames.test', 'ns2.bestnames.test'].each do |item|
      assert(@record.generated_json[:nameservers].include?(item))
    end
  end

  def test_whois_record_has_no_disclaimer_if_Setting_is_blank
    Setting.stubs(:registry_whois_disclaimer, '') do
      refute(@record.json['disclaimer'])
    end
  end

  def test_generates_json_with_registrant
    contact = contacts(:john)
    contact.update!(name: 'John', kind: 'priv', email: 'john@shop.test',
                    updated_at: Time.zone.parse('2010-07-05'),
                    disclosed_attributes: %w[name])

    domain = domains(:shop)
    domain.update!(registrant: contact.becomes(Registrant))

    whois_record = whois_records(:shop)
    whois_record.update!(json: {})

    generated_json = whois_record.generate_json
    assert_equal 'John', generated_json[:registrant]
    assert_equal 'priv', generated_json[:registrant_kind]
    assert_equal 'john@shop.test', generated_json[:email]
    assert_equal '2010-07-05T00:00:00+03:00', generated_json[:registrant_changed]
    assert_equal %w[name], generated_json[:registrant_disclosed_attributes]
  end

  def test_generates_json_with_admin_contacts
    contact = contacts(:john)
    contact.update!(name: 'John', email: 'john@shop.test',
                    updated_at: Time.zone.parse('2010-07-05'),
                    disclosed_attributes: %w[name])

    domain = domains(:shop)
    domain.admin_contacts = [contact]

    whois_record = whois_records(:shop)
    whois_record.update!(json: {})

    admin_contact_json = whois_record.generate_json[:admin_contacts].first
    assert_equal 'John', admin_contact_json[:name]
    assert_equal 'john@shop.test', admin_contact_json[:email]
    assert_equal '2010-07-05T00:00:00+03:00', admin_contact_json[:changed]
    assert_equal %w[name], admin_contact_json[:disclosed_attributes]
  end

  def test_generates_json_with_tech_contacts
    contact = contacts(:john)
    contact.update!(name: 'John', email: 'john@shop.test',
                    updated_at: Time.zone.parse('2010-07-05'),
                    disclosed_attributes: %w[name])

    domain = domains(:shop)
    domain.tech_contacts = [contact]

    whois_record = whois_records(:shop)
    whois_record.update!(json: {})

    tech_contact_json = whois_record.generate_json[:tech_contacts].first
    assert_equal 'John', tech_contact_json[:name]
    assert_equal 'john@shop.test', tech_contact_json[:email]
    assert_equal '2010-07-05T00:00:00+03:00', tech_contact_json[:changed]
    assert_equal %w[name], tech_contact_json[:disclosed_attributes]
  end
end
