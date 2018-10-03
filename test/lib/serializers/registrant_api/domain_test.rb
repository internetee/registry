require 'test_helper'
require 'serializers/registrant_api/domain'

class SerializersRegistrantApiDomainTest < ApplicationIntegrationTest
  def setup
    @domain = domains(:airport)
    @serializer = Serializers::RegistrantApi::Domain.new(@domain)
    @json = @serializer.to_json
  end

  def test_returns_uuid_as_id
    assert_equal(@domain.uuid, @json[:id])
  end

  def test_returns_domain_locked_by_registrant_time_or_nil
    assert_not(@json[:locked_by_registrant_at])

    travel_to Time.zone.parse('2010-07-05 10:30')
    @domain.apply_registry_lock
    serializer_for_locked_domain = Serializers::RegistrantApi::Domain.new(@domain.reload)
    new_json = serializer_for_locked_domain.to_json

    assert_equal(Time.zone.parse('2010-07-05 10:30'), new_json[:locked_by_registrant_at])
    travel_back
  end

  def test_returns_registrar_name
    assert_equal({name: 'Best Names', website: 'bestnames.test' }, @json[:registrar])
  end

  def test_returns_nameserver_hostnames_or_an_empty_array
    expected_nameserver_1 = {
      hostname: 'ns1.bestnames.test',
      ipv4: ['192.0.2.2'],
      ipv6: ['2001:db8::2']
    }

    expected_nameserver_2 = {
      hostname: 'ns2.bestnames.test',
      ipv4: ['192.0.2.0', '192.0.2.3', '192.0.2.1'],
      ipv6: ['2001:db8::1']
    }

    assert(@json[:nameservers].include?(expected_nameserver_1))
    assert(@json[:nameservers].include?(expected_nameserver_2))

    other_domain = domains(:hospital)
    other_serializer = Serializers::RegistrantApi::Domain.new(other_domain)
    new_json = other_serializer.to_json

    assert_equal([], new_json[:nameservers])
  end

  def test_other_fields_are_also_present
    keys = %i[id name registrar registered_at valid_to created_at updated_at
              registrant transfer_code name_dirty name_puny period period_unit
              creator_str updator_str legacy_id legacy_registrar_id legacy_registrant_id
              outzone_at delete_at registrant_verification_asked_at
              registrant_verification_token pending_json force_delete_at statuses
              locked_by_registrant_at reserved status_notes nameservers]

    assert_equal(keys, @json.keys & keys)
  end
end
