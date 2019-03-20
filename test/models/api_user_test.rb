require 'test_helper'

class ApiUserTest < ActiveSupport::TestCase
  setup do
    @user = users(:api_bestnames)
  end

  def test_finds_user_by_id_card
    id_card = IdCard.new
    id_card.personal_code = 'one'

    @user.update!(identity_code: 'one')
    assert_equal @user, ApiUser.find_by_id_card(id_card)

    @user.update!(identity_code: 'another')
    assert_nil ApiUser.find_by_id_card(id_card)
  end
end