require 'test_helper'

class RegistrarAccountTest < ApplicationSystemTestCase
  setup do
    @registrar = registrars(:bestnames)
    sign_in users(:api_bestnames)
  end

  def test_updates_account
    new_billing_email = 'new@registrar.test'
    assert_not_equal new_billing_email, @registrar.billing_email

    visit registrar_account_path
    click_on 'Edit'

    fill_in 'Billing email', with: new_billing_email
    click_on 'Save changes'

    assert_text 'Your account has been updated'
    assert_text new_billing_email
  end
end