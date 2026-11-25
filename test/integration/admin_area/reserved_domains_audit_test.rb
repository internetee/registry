require 'test_helper'

class AdminAreaReservedDomainsAuditTest < ApplicationIntegrationTest
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)
    @reserved_domain = reserved_domains(:one)
  end

  def test_create_records_admin_audit
    assert_difference 'ReservedDomain.count' do
      post admin_reserved_domains_path, params: { reserved_domain: { name: 'admin-created.test' } }
    end

    version = Version::ReservedDomainVersion.where(item_id: ReservedDomain.find_by(name: 'admin-created.test').id).last
    assert_equal 'create', version.event
    assert_equal 'admin', version.source
    assert_equal 'admin_created', version.reason
    assert_equal 'admin-created.test', version.domain_name
  end

  def test_update_records_admin_audit_with_reason_note
    patch admin_reserved_domain_path(@reserved_domain), params: {
      reserved_domain: { password: 'rotated-pw' },
      reason_note: 'Rotate reservation password'
    }

    version = Version::ReservedDomainVersion.where(item_id: @reserved_domain.id).last
    assert_equal 'update', version.event
    assert_equal 'admin', version.source
    assert_equal 'admin_updated', version.reason
    assert_equal 'Rotate reservation password', version.reason_note
  end

  def test_update_without_reason_note_is_rejected
    patch admin_reserved_domain_path(@reserved_domain), params: {
      reserved_domain: { password: 'rotated-pw' }
    }

    assert_response :ok
    assert_equal 'Reason is required', flash[:alert]
    assert_equal 'reserved-001', @reserved_domain.reload.password
  end

  def test_delete_records_admin_audit_with_reason_note
    get delete_admin_reserved_domain_path(@reserved_domain), params: { reason_note: 'Duplicate reservation' }

    assert_redirected_to admin_reserved_domains_path
    assert_not ReservedDomain.exists?(@reserved_domain.id)

    version = Version::ReservedDomainVersion.where(item_id: @reserved_domain.id).last
    assert_equal 'destroy', version.event
    assert_equal 'admin', version.source
    assert_equal 'admin_deleted', version.reason
    assert_equal 'Duplicate reservation', version.reason_note
  end

  def test_delete_without_reason_note_is_rejected
    get delete_admin_reserved_domain_path(@reserved_domain)

    assert_redirected_to admin_reserved_domains_path
    assert_equal 'Reason is required', flash[:alert]
    assert ReservedDomain.exists?(@reserved_domain.id)
  end

  def test_release_to_auction_records_admin_audit
    post release_to_auction_admin_reserved_domains_path, params: {
      reserved_elements: { domain_ids: [@reserved_domain.id] }
    }

    assert_redirected_to admin_auctions_path
    assert_not ReservedDomain.exists?(@reserved_domain.id)
    assert Auction.exists?(domain: @reserved_domain.name)

    version = Version::ReservedDomainVersion.where(item_id: @reserved_domain.id).last
    assert_equal 'destroy', version.event
    assert_equal 'admin', version.source
    assert_equal 'released_to_auction', version.reason
  end

  def test_auction_create_removes_reservation_with_admin_audit
    post admin_auctions_path, params: { domain: @reserved_domain.name }

    assert_not ReservedDomain.exists?(@reserved_domain.id)

    version = Version::ReservedDomainVersion.where(item_id: @reserved_domain.id).last
    assert_equal 'destroy', version.event
    assert_equal 'admin', version.source
    assert_equal 'released_to_auction', version.reason
  end
end
