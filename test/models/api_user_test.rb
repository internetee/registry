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
    assert another_user.valid?
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
