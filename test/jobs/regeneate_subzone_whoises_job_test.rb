require 'test_helper'

class RegenerateSubzoneWhoisesJobTest < ActiveSupport::TestCase
  def test_regenerates_whois_data_only_for_subzones
    subzone = dns_zones(:one).dup
    subzone.origin = 'subzone.test'
    subzone.save

    Whois::Record.where(name: subzone.origin).destroy_all
    Whois::Record.where(name: dns_zones(:one)).destroy_all
    assert_nil Whois::Record.find_by(name: subzone.origin)
    assert_nil Whois::Record.find_by(name: dns_zones(:one).origin)

    RegenerateSubzoneWhoisesJob.run
    assert Whois::Record.find_by(name: subzone.origin)
    assert_nil Whois::Record.find_by(name: dns_zones(:one).origin)
  end
end
