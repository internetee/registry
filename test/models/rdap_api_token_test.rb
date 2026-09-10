require 'test_helper'

class RdapApiTokenTest < ActiveSupport::TestCase
  def test_valid_fixture
    assert rdap_api_tokens(:session_active).valid?
  end

  def test_requires_token_hash_subject_class_and_timestamps
    token = RdapApiToken.new
    assert_not token.valid?
    assert token.errors.key?(:token_hash)
    assert token.errors.key?(:subject)
    assert token.errors.key?(:token_class)
    assert token.errors.key?(:issued_at)
    assert token.errors.key?(:expires_at)
  end

  def test_token_class_inclusion
    token = build_token(token_class: 'admin')
    assert_not token.valid?
    assert token.errors.key?(:token_class)
  end

  def test_token_hash_uniqueness
    dup = build_token(token_hash: rdap_api_tokens(:session_active).token_hash)
    assert_not dup.valid?
    assert dup.errors.key?(:token_hash)
  end

  def test_active_by_hash_returns_active
    token = rdap_api_tokens(:session_active)
    assert_equal token, RdapApiToken.active_by_hash(token.token_hash).first
  end

  def test_active_by_hash_excludes_revoked
    assert_nil RdapApiToken.active_by_hash(rdap_api_tokens(:revoked).token_hash).first
  end

  def test_active_by_hash_excludes_expired
    assert_nil RdapApiToken.active_by_hash(rdap_api_tokens(:expired).token_hash).first
  end

  def test_active_by_hash_unknown_is_nil
    assert_nil RdapApiToken.active_by_hash('no-such-digest').first
  end

  def test_for_subject_scope
    subjects = RdapApiToken.for_subject('EE38001085718').pluck(:subject).uniq
    assert_equal %w[EE38001085718], subjects
  end

  def test_revoke_is_idempotent_and_preserves_time
    token = rdap_api_tokens(:session_active)
    token.revoke!
    first_time = token.reload.revoked_at
    assert_not_nil first_time

    token.revoke!
    assert_equal first_time, token.reload.revoked_at
  end

  def test_touch_last_used_does_not_change_expiry
    token = rdap_api_tokens(:session_active)
    original_expiry = token.expires_at
    token.touch_last_used!
    token.reload
    assert_not_nil token.last_used_at
    assert_equal original_expiry.to_i, token.expires_at.to_i
  end

  private

  def build_token(overrides = {})
    RdapApiToken.new({
      token_hash: 'digest-new',
      subject: 'EE38001085718',
      token_class: 'session',
      issued_at: Time.zone.now,
      expires_at: 8.hours.from_now,
    }.merge(overrides))
  end
end
