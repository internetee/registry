require 'test_helper'

class RegenerateSubzoneWhoisesJobTest < ActiveJob::TestCase
  def test_regenerates_whois_data_only_for_subzones
    subzone = dns_zones(:one).dup
    subzone.origin = 'subzone.test'
    subzone.save

    Whois::Record.where(name: subzone.origin).destroy_all
    Whois::Record.where(name: dns_zones(:one)).destroy_all
    assert_nil Whois::Record.find_by(name: subzone.origin)
    assert_nil Whois::Record.find_by(name: dns_zones(:one).origin)

    perform_enqueued_jobs do
      RegenerateSubzoneWhoisesJob.perform_now
    end
    record = Whois::Record.find_by(name: subzone.origin)
    assert record
    assert record.json['dnssec_keys'].is_a?(Array)

    assert_nil Whois::Record.find_by(name: dns_zones(:one).origin)
  end
end
