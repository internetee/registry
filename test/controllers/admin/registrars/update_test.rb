require 'test_helper'

class RegistrarsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login_as create(:admin_user)
  end

  def test_updates_website
    registrar = create(:registrar, website: 'test')

    patch admin_registrar_path(registrar), registrar: attributes_for(:registrar, website: 'new-website')
    registrar.reload

    assert_equal 'new-website', registrar.website
  end

  def test_updates_email
    registrar = create(:registrar, email: 'test@test.com')

    patch admin_registrar_path(registrar), registrar: attributes_for(:registrar, email: 'new-test@test.com')
    registrar.reload

    assert_equal 'new-test@test.com', registrar.email
  end

  def test_updates_billing_email
    registrar = create(:registrar, billing_email: 'test@test.com')

    patch admin_registrar_path(registrar), registrar: attributes_for(:registrar, billing_email: 'new-test@test.com')
    registrar.reload

    assert_equal 'new-test@test.com', registrar.billing_email
  end

  def test_redirects_to_registrar
    registrar = create(:registrar)
    patch admin_registrar_path(registrar), registrar: attributes_for(:registrar)
    assert_redirected_to admin_registrar_path(registrar)
  end
end
