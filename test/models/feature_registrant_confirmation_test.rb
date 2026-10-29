require 'test_helper'

class FeatureRegistrantConfirmationTest < ActiveSupport::TestCase
  test 'default activation boundary and invalid override' do
    previous = ENV['registrant_confirmation_eeid_required_from']
    ENV['registrant_confirmation_eeid_required_from'] = ''
    travel_to Time.iso8601('2027-01-17T23:59:59+02:00') do
      assert_not Feature.registrant_confirmation_eeid_required?
    end
    travel_to Time.iso8601('2027-01-18T00:00:00+02:00') do
      assert Feature.registrant_confirmation_eeid_required?
    end
    ENV['registrant_confirmation_eeid_required_from'] = 'bad'
    assert Feature.registrant_confirmation_eeid_required?
    ENV['registrant_confirmation_eeid_required_from'] = '2026-12-01T00:00:00+02:00'
    travel_to Time.iso8601('2026-11-30T23:59:59+02:00') do
      assert_not Feature.registrant_confirmation_eeid_required?
    end
    travel_to Time.iso8601('2026-12-01T00:00:00+02:00') do
      assert Feature.registrant_confirmation_eeid_required?
    end
  ensure
    ENV['registrant_confirmation_eeid_required_from'] = previous
  end
end
