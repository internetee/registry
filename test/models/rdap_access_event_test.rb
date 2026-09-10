require 'test_helper'

class RdapAccessEventTest < ActiveSupport::TestCase
  def test_valid_event
    assert build_event.valid?
  end

  def test_requires_requested_at
    assert_invalid_without(:requested_at)
  end

  def test_requires_domain_name
    assert_invalid_without(:domain_name)
  end

  def test_requires_caller_ip
    assert_invalid_without(:caller_ip)
  end

  def test_requires_result_code
    assert_invalid_without(:result_code)
  end

  def test_requires_accessor_name
    assert_invalid_without(:accessor_name)
  end

  def test_requires_category
    assert_invalid_without(:category)
  end

  def test_requires_grant_ref
    assert_invalid_without(:grant_ref)
  end

  # AC8 / AC19: organization_name and request_id are NOT required.
  def test_valid_with_blank_organization_name_and_request_id
    event = build_event(organization_name: nil, request_id: nil)
    assert event.valid?
    assert event.save
    assert_nil event.reload.organization_name
    assert_nil event.request_id
  end

  # AC18: create-only immutability — a fresh create succeeds, but any mutation
  # or destroy of a persisted row raises.
  def test_create_succeeds
    assert_difference 'RdapAccessEvent.count', 1 do
      build_event.save!
    end
  end

  def test_update_raises
    event = build_event.tap(&:save!)
    assert_raises(ActiveRecord::ReadOnlyRecord) { event.update!(domain_name: 'changed.ee') }
  end

  def test_save_on_persisted_row_raises
    event = build_event.tap(&:save!)
    event.domain_name = 'changed.ee'
    assert_raises(ActiveRecord::ReadOnlyRecord) { event.save }
  end

  def test_destroy_raises
    event = build_event.tap(&:save!)
    assert_raises(ActiveRecord::ReadOnlyRecord) { event.destroy }
  end

  # AC20: NOT a paper_trail model — it does not include the Versions concern.
  def test_is_not_a_paper_trail_model
    assert_not RdapAccessEvent.include?(Versions)
    assert_not RdapAccessEvent.respond_to?(:paper_trail_options)
  end

  private

  def build_event(attrs = {})
    RdapAccessEvent.new({
      requested_at: Time.zone.now,
      domain_name: 'example.ee',
      caller_ip: '192.0.2.1',
      result_code: 200,
      organization_name: 'police',
      accessor_name: 'Police Officer One',
      category: 'police',
      grant_ref: 'a1b2c3d4-0000-0000-0000-000000000001',
      request_id: 'req-test',
    }.merge(attrs))
  end

  def assert_invalid_without(field)
    event = build_event(field => nil)
    assert event.invalid?
    assert_includes event.errors.attribute_names, field
  end
end
