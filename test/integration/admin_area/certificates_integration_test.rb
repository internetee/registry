require 'test_helper'

class AdminCertificatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess

  setup do
    @admin = users(:admin)
    sign_in @admin

    @api_user = users(:api_bestnames)
    @certificate = certificates(:api)
    @password = ENV['ca_key_password'] || 'test'
  end

  def test_new_renders_successfully
    get new_admin_api_user_certificate_path(api_user_id: @api_user.id)

    assert_response :success
  end

  def test_create_certificate_with_valid_csr
    csr_file = fixture_file_upload('files/test_ca/server.csr', 'text/plain')

    assert_difference -> { @api_user.certificates.count } do
      post admin_api_user_certificates_path(api_user_id: @api_user.id),
           params: { certificate: { csr: csr_file } }
    end

    assert_redirected_to admin_api_user_certificate_path(@api_user, Certificate.last)
    assert_equal I18n.t('record_created'), flash[:notice]
  end

  def test_destroy_certificate
    assert_difference -> { Certificate.count }, -1 do
      delete admin_api_user_certificate_path(api_user_id: @api_user.id, id: @certificate.id)
    end

    assert_redirected_to admin_registrar_api_user_path(@api_user.registrar, @api_user)
    assert_equal I18n.t('record_deleted'), flash[:notice]
  end

  def test_sign_certificate
    Certificate.stub_any_instance(:sign!, true) do
      post sign_admin_api_user_certificate_path(api_user_id: @api_user.id, id: @certificate.id),
           params: { certificate: { password: @password } }
    end

    assert_redirected_to admin_api_user_certificate_path(@api_user, @certificate)
    assert_equal I18n.t('record_updated'), flash[:notice]
  end

  def test_revoke_certificate
    Certificate.stub_any_instance(:revoke!, true) do
      post revoke_admin_api_user_certificate_path(api_user_id: @api_user.id, id: @certificate.id),
           params: { certificate: { password: @password } }
    end

    assert_redirected_to admin_api_user_certificate_path(@api_user, @certificate)
    assert_equal I18n.t('record_updated'), flash[:notice]
  end
end 
