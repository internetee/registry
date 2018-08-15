require 'test_helper'
require 'openssl'
require_relative '../../../lib/auth_token/auth_token_creator'

class AuthTokenCreatorTest < ActiveSupport::TestCase
  def setup
    super

    @user = users(:registrant)
    time = Time.zone.parse('2010-07-05 00:30:00 +0000')
    @random_bytes = SecureRandom.random_bytes(32)
    @token_creator = AuthTokenCreator.new(@user, @random_bytes, time)
  end

  def test_hashable_is_constructed_as_expected
    expected_hashable = { user_ident: 'US-1234', user_username: 'Registrant User',
                          expires_at: '2010-07-05 00:30:00 UTC' }.to_json

    assert_equal(expected_hashable, @token_creator.hashable)
  end

  def test_encrypted_token_is_decryptable
    encryptor = OpenSSL::Cipher::AES.new(256, :CBC)
    encryptor.decrypt
    encryptor.key = @random_bytes

    base64_decoded = Base64.urlsafe_decode64(@token_creator.encrypted_token)
    result = encryptor.update(base64_decoded) + encryptor.final

    hashable = { user_ident: 'US-1234', user_username: 'Registrant User',
                 expires_at: '2010-07-05 00:30:00 UTC' }.to_json

    assert_equal(hashable, result)
  end

  def test_token_in_json_returns_expected_values
    @token_creator.stub(:encrypted_token, 'super_secure_token') do
      token = @token_creator.token_in_hash
      assert_equal('2010-07-05 00:30:00 UTC', token[:expires_at])
      assert_equal('Bearer', token[:type])
    end
  end

  def test_create_with_defaults_injects_values
    travel_to Time.zone.parse('2010-07-05 00:30:00 +0000')

    token_creator_with_defaults = AuthTokenCreator.create_with_defaults(@user)
    assert_equal(Rails.application.config.secret_key_base, token_creator_with_defaults.key)
    assert_equal('2010-07-05 02:30:00 UTC', token_creator_with_defaults.expires_at)

    travel_back
  end
end
