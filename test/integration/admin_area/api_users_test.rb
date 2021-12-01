require 'test_helper'

class AdminAreaRegistrarsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @api_user = users(:api_bestnames)
    sign_in users(:admin)
  end

  def test_set_test_date_to_api_user
    date = Time.zone.now - 10.minutes

    api_user = @api_user.dup
    api_user.accreditation_date = date
    api_user.accreditation_expire_date = api_user.accreditation_date + 1.year
    api_user.save

    assert_nil @api_user.accreditation_date
    assert_equal api_user.accreditation_date, date

    Spy.on_instance_method(Actions::GetAccrResultsFromAnotherDb, :userapi_from_another_db).and_return(api_user)

    post set_test_date_to_api_user_admin_registrars_path, params: { user_api_id: @api_user.id }
    @api_user.reload

    assert_equal @api_user.accreditation_date.to_date,  api_user.accreditation_date.to_date
    assert_equal @api_user.accreditation_expire_date.to_date,  api_user.accreditation_expire_date.to_date
  end
end
