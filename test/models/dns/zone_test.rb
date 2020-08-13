require 'test_helper'

class DNS::ZoneTest < ActiveSupport::TestCase
  def test_valid_zone_fixture_is_valid
    assert valid_zone.valid?, proc { valid_zone.errors.full_messages }
  end

  def test_invalid_without_origin
    zone = valid_zone
    zone.origin = ''
    assert zone.invalid?
  end

  def test_invalid_when_origin_is_already_taken
    zone = valid_zone
    another_zone = zone.dup
    assert another_zone.invalid?
  end

  def test_invalid_without_ttl
    zone = valid_zone
    zone.ttl = ''
    assert zone.invalid?
  end

  def test_validates_ttl_format
    zone = valid_zone

    zone.ttl = 'text'
    assert zone.invalid?

    zone.ttl = '1.1'
    assert zone.invalid?

    zone.ttl = '1'
    assert zone.valid?
  end

  def test_invalid_without_refresh
    zone = valid_zone
    zone.refresh = ''
    assert zone.invalid?
  end

  def test_validates_refresh_format
    zone = valid_zone

    zone.refresh = 'text'
    assert zone.invalid?

    zone.refresh = '1.1'
    assert zone.invalid?

    zone.refresh = '1'
    assert zone.valid?
  end

  def test_invalid_without_retry
    zone = valid_zone
    zone.retry = ''
    assert zone.invalid?
  end

  def test_validates_retry_format
    zone = valid_zone

    zone.retry = 'text'
    assert zone.invalid?

    zone.retry = '1.1'
    assert zone.invalid?

    zone.retry = '1'
    assert zone.valid?
  end

  def test_invalid_without_expire
    zone = valid_zone
    zone.expire = ''
    assert zone.invalid?
  end

  def test_validates_expire_format
    zone = valid_zone

    zone.expire = 'text'
    assert zone.invalid?

    zone.expire = '1.1'
    assert zone.invalid?

    zone.expire = '1'
    assert zone.valid?
  end

  def test_invalid_without_minimum_ttl
    zone = valid_zone
    zone.minimum_ttl = ''
    assert zone.invalid?
  end

  def test_validates_minimum_ttl_format
    zone = valid_zone

    zone.minimum_ttl = 'text'
    assert zone.invalid?

    zone.minimum_ttl = '1.1'
    assert zone.invalid?

    zone.minimum_ttl = '1'
    assert zone.valid?
  end

  def test_invalid_without_email
    zone = valid_zone
    zone.email = ''
    assert zone.invalid?
  end

  def test_invalid_without_master_nameserver
    zone = valid_zone
    zone.master_nameserver = ''
    assert zone.invalid?
  end

  def test_determines_if_subzone
    zone = valid_zone
    zone.update(origin: 'pri.ee')
    assert zone.subzone?
  end

  def test_updates_whois_after_update
    subzone = dns_zones(:one).dup

    subzone.origin = 'sub.zone'
    subzone.save

    whois_record = Whois::Record.find_by(name: subzone.origin)
    assert whois_record.present?
  end

  def test_deletes_whois_record_after_destroy
    subzone = dns_zones(:one).dup

    subzone.origin = 'sub.zone'
    subzone.save

    assert Whois::Record.find_by(name: subzone.origin).present?

    subzone.destroy
    assert_nil Whois::Record.find_by(name: subzone.origin)
  end

  private

  def valid_zone
    dns_zones(:one)
  end
end
