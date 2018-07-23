require 'test_helper'
require_relative '../../../lib/auth_token/auth_token_decryptor'
require_relative '../../../lib/auth_token/auth_token_creator'

class AuthTokenDecryptorTest < ActiveSupport::TestCase
  def setup
    super

    travel_to Time.parse("2010-07-05 00:15:00 UTC")
    @user = users(:registrant)

    # For testing purposes, the token needs to be random and long enough, hence:
    @key = "b8+PtSq1+iXzUVnGEqciKsITNR0KmLl7uPiSTHbteqCoEBdbMLUl3GXlIDWD\nDZp1hIgKWnIMPNEgbuCa/7qccA==\n"
    @faulty_key = "FALSE+iXzUVnGEqciKsITNR0KmLl7uPiSTHbteqCoEBdbMLUl3GXlIDWD\nDZp1hIgKWnIMPNEgbuCa/7qccA==\n"

    # this token corresponds to:
    # {:user_ident=>"US-1234", :user_username=>"Registrant User", :expires_at=>"2010-07-05 02:15:00 UTC"}
    @access_token = "q27NWIsKD5snWj9vZzJ0RcOYvgocEyu7H9yCaDjfmGi54sogovpBeALMPWTZHMcdFQzSiq6b4cI0p5tO0_5UEOHic2jRzNW7mkhi-bn-Y2Wlnw7jhMpxw6VwJR8QEoDzjkcNxnKBN6OKF4nssa60ZQ=="
  end

  def teardown
    super

    travel_back
  end

  def test_decrypt_token_returns_a_hash_when_token_is_valid
    decryptor = AuthTokenDecryptor.new(@access_token, @key)

    assert(decryptor.decrypt_token.is_a?(Hash))
  end

  def test_decrypt_token_return_false_when_token_is_invalid
    faulty_decryptor = AuthTokenDecryptor.new(@access_token, @faulty_key)
    refute(faulty_decryptor.decrypt_token)
  end

  def test_decrypt_token_return_false_when_token_is_nil
    faulty_decryptor = AuthTokenDecryptor.new(nil, @key)
    refute(faulty_decryptor.decrypt_token)
  end

  def test_valid_returns_true_for_valid_token
    decryptor = AuthTokenDecryptor.new(@access_token, @key)
    decryptor.decrypt_token

    assert(decryptor.valid?)
  end

  def test_valid_returns_false_for_invalid_token
    faulty_decryptor = AuthTokenDecryptor.new(@access_token, @faulty_key)
    faulty_decryptor.decrypt_token

    refute(faulty_decryptor.valid?)
  end

  def test_valid_returns_false_for_expired_token
    travel_to Time.parse("2010-07-05 10:15:00 UTC")

    decryptor = AuthTokenDecryptor.new(@access_token, @key)
    decryptor.decrypt_token

    refute(decryptor.valid?)
  end

  def test_returns_false_for_non_existing_user
    # This token was created from an admin user and @key. Decrypted, it corresponds to:
    # {:user_ident=>nil, :user_username=>"test", :expires_at=>"2010-07-05 00:15:00 UTC"}
    other_token = "rMkjgpyRcj2xOnHVwvvQ5RAS0yQepUSrw3XM5BrwM4TMH-h-TBeLve9InC_zaPneMMnCs0NHQHt1EpH95A2Yhdk6Ge6HQ-4gN5L0THDywCO2vHKGucPxbd6g6wOSaOnR"

    decryptor = AuthTokenDecryptor.new(other_token, @key)
    decryptor.decrypt_token

    refute(decryptor.valid?)
  end

  def test_create_with_defaults_injects_values
    decryptor = AuthTokenDecryptor.create_with_defaults(@access_token)

    assert_equal(Rails.application.config.secret_key_base, decryptor.key)
  end
end
