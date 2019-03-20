require 'test_helper'

class IdCardAuthenticatableTest < ActiveSupport::TestCase
  def test_valid_when_id_card_data_is_present_in_env
    strategy = Devise::Strategies::IdCardAuthenticatable.new({ 'SSL_CLIENT_S_DN_CN' => 'some' })
    assert strategy.valid?
  end

  def test_not_valid_when_id_card_data_is_absent_in_env
    strategy = Devise::Strategies::IdCardAuthenticatable.new({})
    assert_not strategy.valid?
  end
end