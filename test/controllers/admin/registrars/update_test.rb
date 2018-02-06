require 'test_helper'

class RegistrarsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:admin)
    @registrar = registrars(:bestnames)
  end

  def test_updates_website
    patch admin_registrar_path(@registrar), registrar: @registrar.attributes.merge(website: 'new.example.com')
    @registrar.reload

    assert_equal 'new.example.com', @registrar.website
  end

  def test_updates_email
    patch admin_registrar_path(@registrar), registrar: @registrar.attributes.merge(email: 'new@example.com')
    @registrar.reload

    assert_equal 'new@example.com', @registrar.email
  end

  def test_updates_billing_email
    patch admin_registrar_path(@registrar),
          registrar: @registrar.attributes.merge(billing_email: 'new-billing@example.com')
    @registrar.reload

    assert_equal 'new-billing@example.com', @registrar.billing_email
  end
end
