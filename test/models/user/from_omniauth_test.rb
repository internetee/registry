# frozen_string_literal: true

require 'test_helper'

class UserFromOmniauthTest < ActiveSupport::TestCase
  setup do
    @user = users(:api_bestnames)
  end

  test 'finds active api user by subject when uid matches' do
    @user.update_columns(subject: 'EE60001019906', verified_at: nil, active: true)

    found = ApiUser.from_omniauth('uid' => 'EE60001019906')

    assert_equal @user, found
  end

  test 'does not match when subject is blank' do
    @user.update_columns(subject: nil, verified_at: Time.zone.now, active: true)

    assert_nil ApiUser.from_omniauth('uid' => 'EE60001019906')
  end

  test 'does not match by identity_code when subject is blank' do
    @user.update_columns(subject: nil, identity_code: '1234')

    assert_nil ApiUser.from_omniauth('uid' => 'EE1234')
  end

  test 'returns nil when uid is blank' do
    assert_nil ApiUser.from_omniauth('uid' => '')
    assert_nil ApiUser.from_omniauth({})
  end

  test 'returns nil when no api user matches subject' do
    assert_nil ApiUser.from_omniauth('uid' => 'XXunknown')
  end

  test 'does not match inactive api users' do
    @user.update_columns(subject: 'EE1234', active: false, verified_at: Time.zone.now)

    assert_nil ApiUser.from_omniauth('uid' => 'EE1234')
  end
end
