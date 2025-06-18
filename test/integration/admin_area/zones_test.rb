require 'test_helper'

class AdminAreaZonesIntegrationTest < ApplicationIntegrationTest
  setup do
    @zone = dns_zones(:one)
    sign_in users(:admin)
  end

  def test_updates_zone
    new_master_nameserver = 'new.test'
    assert_not_equal new_master_nameserver, @zone.master_nameserver

    patch admin_zone_path(@zone), params: { zone: { master_nameserver: new_master_nameserver } }
    @zone.reload

    assert_equal new_master_nameserver, @zone.master_nameserver
  end

  def test_downloads_zone_file
    post admin_zonefiles_path(origin: @zone.origin)

    assert_response :ok
    assert_equal 'text/plain', response.headers['Content-Type']
    assert_equal "attachment; filename=\"test.txt\"; filename*=UTF-8''test.txt", response.headers['Content-Disposition']
    assert_not_empty response.body
  end

  def test_shows_new_form
    get new_admin_zone_path
    assert_response :success

    unless response.body.include?('<form')
      puts "[DEBUG] 'form' not found in response body for new_admin_zone_path"
      puts response.body
    end

    assert_includes response.body, '<form', "'form' element not found"
  end

  def test_shows_index
    get admin_zones_path
    assert_response :success

    unless response.body.include?('<table')
      puts "[DEBUG] 'table' not found in response body for admin_zones_path"
      puts response.body
    end

    assert_includes response.body, '<table', "'table' element not found"
  end

  def test_creates_zone_successfully
    assert_difference 'DNS::Zone.count' do
      post admin_zones_path, params: {
        zone: {
          origin: 'example.org',
          ttl: 3600,
          refresh: 1200,
          retry: 1800,
          expire: 3600000,
          minimum_ttl: 600,
          email: 'admin@example.org',
          master_nameserver: 'ns1.example.org'

        }
      }
    end

    assert_redirected_to admin_zones_url
    follow_redirect!
    assert_response :success

    # If the table is not found in response body, print the response body
    unless response.body.include?('<table')
      puts "[DEBUG] 'table' not found after redirect following zone creation"
      puts response.body
    end

    assert_includes response.body, '<table', "'table' element not found after zone cration"
  end

  def test_fails_to_create_zone_with_invalid_data
    assert_no_difference 'DNS::Zone.count' do
      post admin_zones_path, params: {
        zone: {
          origin: '',
          email: ''
        }
      }

      assert_response :success

      # If the form is not found in response body, print the response body
      unless response.body.include?('<form')
        puts "[DEBUG] 'form' not found in response body for edit_admin_zone_path"
        puts response.body
      end

      assert_includes response.body, '<form', "'form' element not found"
    end
  end

  def test_shows_edit_form
    get edit_admin_zone_path(@zone)
    assert_response :success
    assert_includes response.body, '<form', "'form' element not found in edit form"
  end

  def test_fails_to_update_zone_with_invalid_data
    patch admin_zone_path(@zone), params: { zone: { origin: '' }}

    assert_response :success

    # If the form is not found in response body, print the response body
    unless response.body.include?('<form')
      puts "[DEBUG] 'form' not found in response body after invalid update"
      puts response.body
    end

    assert_includes response.body, '<form', "'form' element not found after invalid update"

    @zone.reload
    assert_not_equal '', @zone.origin
  end

  def test_redirects_to_index_after_successful_operations
    # Test redirect_to_index private method through public methods
    post admin_zones_path, params: {
      zone: {
        origin: 'redirect-test.org',
        ttl: 3600,
        refresh: 1200,
        retry: 1800,
        expire: 3600000,
        minimum_ttl: 600,
        email: 'admin@redirect-test.org',
        master_nameserver: 'ns1.redirect-test.org'
      }
    }
    
    assert_redirected_to admin_zones_url
  end
end
