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
      category: 'police',
      status: 'active',
      valid_from: 1.day.ago,
    }.merge(attrs))
  end

  def create_grant(attrs = {})
    build_grant(attrs).tap(&:save!)
  end
end
