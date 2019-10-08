require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  def test_valid_user_fixture_is_valid
    assert valid_user.valid?, proc { valid_user.errors.full_messages }
  end

  def test_invalid_without_username
    user = valid_user
    user.username = ''
    assert user.invalid?
  end

  def test_invalid_without_password_and_password_confirmation_when_creating
    user = valid_non_persisted_user

    user.password = ''
    user.password_confirmation = ''
    assert user.invalid?

    user.password = valid_password
    user.password_confirmation = user.password
    assert user.valid?
  end

  def test_validates_password_format
    user = valid_non_persisted_user

    user.password = 'a' * (Devise.password_length.min.pred)
    user.password_confirmation = user.password
    assert user.invalid?

    user.password = 'a' * (Devise.password_length.max.next)
    user.password_confirmation = user.password
    assert user.invalid?

    user.password = 'a' * Devise.password_length.min
    user.password_confirmation = user.password
    assert user.valid?

    user.password = 'a' * Devise.password_length.max
    user.password_confirmation = user.password
    assert user.valid?
  end

  def test_requires_password_confirmation
    user = valid_non_persisted_user
    user.password = valid_password

    user.password_confirmation = ''
    assert user.invalid?

    user.password_confirmation = 'another'
    assert user.invalid?

    user.password_confirmation = user.password
    assert user.valid?, proc { user.errors.full_messages }
  end

  def test_invalid_without_email
    user = valid_user
    user.email = ''
    assert user.invalid?
  end

  def test_validates_email_format
    user = valid_user

    user.email = 'invalid'
    assert user.invalid?

    user.email = 'valid@registry.test'
    assert user.valid?
  end

  def test_invalid_when_email_is_already_taken
    another_user = valid_user
    user = valid_non_persisted_user

    user.email = another_user.email
    assert user.invalid?

    user.email = 'new-user@registry.test'
    assert user.valid?, proc { user.errors.full_messages }
  end

  def test_invalid_without_country_code
    user = valid_user
    user.country_code = ''
    assert user.invalid?
  end

  def test_invalid_without_roles
    user = valid_user
    user.roles = []
    assert user.invalid?
  end

  def test_valid_without_identity_code
    user = valid_user
    user.identity_code = ''
    assert user.valid?
  end

  def test_invalid_without_identity_code_when_country_code_is_estonia
    user = valid_user
    user.country_code = 'EE'

    user.identity_code = ''

    assert user.invalid?
  end

  # https://en.wikipedia.org/wiki/National_identification_number#Estonia
  def test_validates_identity_code_format_when_country_code_is_estonia
    user = valid_user
    user.country_code = 'EE'

    user.identity_code = '47101010030'
    assert user.invalid?

    user.identity_code = '47101010033'
    assert user.valid?
  end

  private

  def valid_user
    users(:admin)
  end

  def valid_non_persisted_user
    user = valid_user.dup
    user.password = user.password_confirmation = valid_password
    user.email = 'another@registry.test'
    user
  end

  def valid_password
    'a' * Devise.password_length.min
  end
end
