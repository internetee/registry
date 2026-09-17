require 'test_helper'

class RdapPrivilegeGrantTest < ActiveSupport::TestCase
  def test_valid_grant
    assert build_grant.valid?
  end

  def test_requires_eeid_subject
    grant = build_grant(eeid_subject: nil)
    assert grant.invalid?
    assert_includes grant.errors.attribute_names, :eeid_subject
  end

  def test_requires_full_name
    grant = build_grant(full_name: nil)
    assert grant.invalid?
    assert_includes grant.errors.attribute_names, :full_name
  end

  def test_requires_legal_basis_ref
    grant = build_grant(legal_basis_ref: nil)
    assert grant.invalid?
    assert_includes grant.errors.attribute_names, :legal_basis_ref
  end

  def test_personal_id_code_is_optional
    assert build_grant(personal_id_code: nil).valid?
    assert build_grant(personal_id_code: '38001085718').valid?
  end

  def test_valid_with_only_valid_from
    assert build_grant(valid_from: 1.day.ago, valid_until: nil).valid?
  end

  def test_statuses_do_not_include_expired
    assert_equal %w[active revoked suspended], RdapPrivilegeGrant::STATUSES
  end

  def test_expired_is_derived_from_valid_until
    active = build_grant(status: 'active', valid_from: 30.days.ago, valid_until: 1.day.ago)
    assert active.expired?
    assert_equal 'expired', active.display_status

    live = build_grant(status: 'active', valid_from: 1.day.ago, valid_until: 30.days.from_now)
    assert_not live.expired?
    assert_equal 'active', live.display_status
  end

  def test_active_for_subject_returns_nothing_immediately_after_revoke
    subject = 'EE44444444444'
    grant = create_grant(eeid_subject: subject, status: 'active', valid_from: 2.days.ago)
    assert_equal [grant.id], RdapPrivilegeGrant.active_for_subject(subject).map(&:id)

    grant.update!(status: 'revoked')
    assert_empty RdapPrivilegeGrant.active_for_subject(subject)
  end

  def test_category_must_be_in_list
    assert build_grant(category: 'mayor').invalid?
    RdapPrivilegeGrant::CATEGORIES.each do |category|
      assert build_grant(category: category).valid?, "#{category} should be valid"
    end
  end

  def test_status_must_be_in_list
    assert build_grant(status: 'paused').invalid?
  end

  def test_valid_until_must_be_after_valid_from
    grant = build_grant(valid_from: Time.zone.now, valid_until: 1.day.ago)
    assert grant.invalid?
    assert_includes grant.errors.attribute_names, :valid_until
  end

  def test_assigns_uuid_on_create
    grant = build_grant
    assert_nil grant.uuid
    grant.save!
    assert grant.uuid.present?
  end

  def test_active_for_subject_returns_only_active_window
    subject = 'EE12345678901'
    active = create_grant(eeid_subject: subject, status: 'active',
                          valid_from: 2.days.ago, valid_until: nil)
    create_grant(eeid_subject: subject, status: 'revoked', valid_from: 2.days.ago)
    create_grant(eeid_subject: subject, status: 'active',
                 valid_from: 1.day.from_now) # not yet valid
    create_grant(eeid_subject: subject, status: 'active',
                 valid_from: 5.days.ago, valid_until: 1.day.ago) # expired

    result = RdapPrivilegeGrant.active_for_subject(subject)
    assert_equal [active.id], result.map(&:id)
  end

  def test_active_for_subject_orders_latest_valid_from_first
    subject = 'EE99999999999'
    older = create_grant(eeid_subject: subject, status: 'active', valid_from: 10.days.ago)
    newer = create_grant(eeid_subject: subject, status: 'active', valid_from: 1.day.ago)

    result = RdapPrivilegeGrant.active_for_subject(subject)
    assert_equal [newer.id, older.id], result.map(&:id)
  end

  private

  def build_grant(attrs = {})
    RdapPrivilegeGrant.new({
      eeid_subject: 'EE38001085718',
      full_name: 'Grant Holder',
      legal_basis_ref: 'MoU-2026-999',
      category: 'police',
      status: 'active',
      valid_from: 1.day.ago,
    }.merge(attrs))
  end

  def create_grant(attrs = {})
    build_grant(attrs).tap(&:save!)
  end
end
