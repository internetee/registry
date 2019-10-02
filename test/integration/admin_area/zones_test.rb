require 'test_helper'

class AdminAreaZonesIntegrationTest < ApplicationIntegrationTest
  setup do
    @zone = dns_zones(:one)
    sign_in users(:admin)
  end

  def test_updates_zone
    new_master_nameserver = 'new.test'
    assert_not_equal new_master_nameserver, @zone.master_nameserver

    patch admin_zone_path(@zone), zone: { master_nameserver: new_master_nameserver }
    @zone.reload

    assert_equal new_master_nameserver, @zone.master_nameserver
  end

  def test_downloads_zone_file
    post admin_zonefiles_path(origin: @zone.origin)

    assert_response :ok
    assert_equal 'text/plain', response.headers['Content-Type']
    assert_equal 'attachment; filename="test.txt"', response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end
