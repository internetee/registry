require 'test_helper'

class ApiUserTest < ActiveSupport::TestCase
  setup do
    @user = users(:api_bestnames)
  end

  def test_valid_user_fixture_is_valid
    assert valid_user.valid?, proc { valid_user.errors.full_messages }
  end

  def test_invalid_without_username
    user = valid_user
    user.username = ''
    assert user.invalid?
  end

  def test_invalid_when_username_is_already_taken
    user = valid_user
    another_user = user.dup

    assert another_user.invalid?

    another_user.username = 'another'
    another_user.identity_code = ''
    assert another_user.valid?
  end

  def test_invalid_when_one_registrar_and_identity_code_is_already_taken
    user = valid_user
    another_user = user.dup

    assert another_user.invalid?

    another_user.username = 'another'
    assert another_user.invalid?
  end

  def test_valid_when_another_registrar_and_identity_code_is_already_taken
    another_user = valid_user
    @user.identity_code = another_user.identity_code
    assert @user.valid?
  end

  def test_invalid_without_password
    user = valid_user
    user.plain_text_password = ''
    assert user.invalid?
  end

  def test_validates_password_format
    user = valid_user
    min_length = ApiUser.min_password_length

    user.plain_text_password = 'a' * (min_length.pred)
    assert user.invalid?

    user.plain_text_password = 'a' * min_length
    assert user.valid?
  end

  def test_invalid_without_roles
    user = valid_user
    user.roles = []
    assert user.invalid?
  end

  def test_active_by_default
    assert ApiUser.new.active?
  end

  def test_linked_users_by_subject_same_registrar
    login_subject = 'EE60001019906'
    @user.update_columns(subject: login_subject)
    linked = ApiUser.create!(
      username: 'linked_by_subject',
      plain_text_password: 'secret1',
      registrar: @user.registrar,
      roles: ['epp'],
      subject: login_subject,
      verified_at: Time.zone.now,
      active: true
    )

    assert_includes @user.linked_users, linked
  end

  def test_linked_users_by_subject_across_registrars
    login_subject = 'GBAB123456'
    @user.update_columns(subject: login_subject)
    linked = ApiUser.create!(
      username: 'linked_other_registrar',
      plain_text_password: 'secret1',
      registrar: registrars(:goodnames),
      roles: ['epp'],
      subject: login_subject,
      verified_at: Time.zone.now,
      active: true
    )

    assert_includes @user.linked_users, linked
  end

  def test_linked_users_empty_when_subject_blank
    @user.update_columns(subject: nil)

    assert_empty @user.linked_users
  end

  def test_linked_users_excludes_inactive_users
    login_subject = 'EE99999999999'
    @user.update_columns(subject: login_subject)
    ApiUser.create!(
      username: 'linked_inactive',
      plain_text_password: 'secret1',
      registrar: @user.registrar,
      roles: ['epp'],
      subject: login_subject,
      active: false
    )

    assert_empty @user.linked_users
  end

  def test_linked_users_excludes_unverified_users
    login_subject = 'EE77777777777'
    @user.update_columns(subject: login_subject)
    ApiUser.create!(
      username: 'linked_unverified',
      plain_text_password: 'secret1',
      registrar: @user.registrar,
      roles: ['epp'],
      subject: login_subject,
      verified_at: nil,
      active: true
    )

    assert_empty @user.linked_users
  end

  def test_linked_with_by_subject_only
    @user.update_columns(subject: 'GBAB1')
    same_subject = ApiUser.new(subject: 'GBAB1')
    different_subject = ApiUser.new(subject: 'other')

    assert @user.linked_with?(same_subject)
    assert_not @user.linked_with?(different_subject)
    assert_not @user.linked_with?(ApiUser.new(subject: nil))
    assert_not @user.linked_with?(nil)
  end

  def test_eligible_for_sign_in_requires_active_verified_subject
    @user.update_columns(active: true, verified_at: Time.zone.now, subject: 'EE1234')
    assert @user.eligible_for_sign_in?

    @user.update_columns(verified_at: nil)
    assert_not @user.eligible_for_sign_in?

    @user.update_columns(verified_at: Time.zone.now, active: false)
    assert_not @user.eligible_for_sign_in?

    @user.update_columns(active: true, subject: nil)
    assert_not @user.eligible_for_sign_in?
  end

  def test_subject_change_clears_verification_status_when_subject_previously_present
    @user.update_columns(
      subject: 'EE1234',
      ident_request_sent_at: 2.days.ago,
      verified_at: 1.day.ago,
      verification_id: 'ver-1',
      verification_pending_at: 3.hours.ago,
      verification_snapshot: { 'sub' => 'EE1234' }
    )

    @user.update!(subject: 'EE9999')
    @user.reload

    assert_nil @user.ident_request_sent_at
    assert_nil @user.verified_at
    assert_nil @user.verification_id
    assert_nil @user.verification_pending_at
    assert_equal({}, @user.verification_snapshot)
  end

  def test_subject_change_notifies_registrar_when_subject_previously_present
    @user.update_columns(
      subject: 'EE1234',
      verified_at: 1.day.ago
    )

    assert_emails 1 do
      @user.update!(subject: 'EE9999')
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal [@user.registrar.email], email.to
    assert_match(@user.username, email.subject)
  end

  def test_setting_subject_first_time_does_not_clear_verification_status
    @user.update_columns(
      subject: nil,
      ident_request_sent_at: 2.days.ago,
      verified_at: 1.day.ago,
      verification_id: 'ver-2',
      verification_pending_at: nil,
      verification_snapshot: { 'sub' => 'EE1234' }
    )

    @user.update!(subject: 'EE1234')
    @user.reload

    assert_not_nil @user.ident_request_sent_at
    assert_not_nil @user.verified_at
    assert_equal 'ver-2', @user.verification_id
    assert_nil @user.verification_pending_at
    assert_equal({ 'sub' => 'EE1234' }, @user.verification_snapshot)
  end

  def test_setting_subject_first_time_does_not_notify_registrar
    @user.update_columns(subject: nil)

    assert_emails 0 do
      @user.update!(subject: 'EE1234')
    end
  end

  def test_verifies_pki_status
    certificate = certificates(:api)

    assert @user.pki_ok?(certificate.crt, certificate.common_name, api: true)
    assert_not @user.pki_ok?(certificate.crt, 'invalid-cn', api: true)

    certificate = certificates(:registrar)

    assert @user.pki_ok?(certificate.crt, certificate.common_name, api: false)
    assert_not @user.pki_ok?(certificate.crt, 'invalid-cn', api: false)

    certificate.update(revoked: true)
    assert_not @user.pki_ok?(certificate.crt, certificate.common_name, api: false)

    certificate = certificates(:api)
    certificate.update(revoked: true)
    assert_not @user.pki_ok?(certificate.crt, certificate.common_name, api: true)
  end

  private

  def valid_user
    users(:api_bestnames)
  end
end
