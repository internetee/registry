require 'test_helper'

class SsoTaraControllerTest < ApplicationIntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @api_user = users(:api_bestnames)
    @inactive_user = users(:api_goodnames)
  end

  def test_registrar_callback_calls_from_omniauth
    ApiUser.stub(:from_omniauth, @api_user) do
      controller = Sso::TaraController.new
      controller.request = ActionController::TestRequest.create({})
      controller.request.env['omniauth.auth'] = { 'uid' => 'test_uid' }
      
      callback_called = false
      callback_user = nil
      callback_registrar = nil
      controller.define_singleton_method(:callback) do |user, registrar: true|
        callback_called = true
        callback_user = user
        callback_registrar = registrar
      end
      
      controller.send(:registrar_callback)
      assert callback_called, "callback method should have been called"
      assert_equal @api_user, callback_user
      assert_equal true, callback_registrar
    end
  end

  def test_registrant_callback_calls_find_or_create_by_omniauth_data
    new_user = RegistrantUser.new
    RegistrantUser.stub(:find_or_create_by_omniauth_data, new_user) do
      controller = Sso::TaraController.new
      controller.request = ActionController::TestRequest.create({})
      controller.request.env['omniauth.auth'] = { 'uid' => 'test_uid' }
      
      callback_called = false
      callback_user = nil
      callback_registrar = nil
      controller.define_singleton_method(:callback) do |user, registrar: false|
        callback_called = true
        callback_user = user
        callback_registrar = registrar
      end
      
      controller.send(:registrant_callback)
      assert callback_called, "callback method should have been called"
      assert_equal new_user, callback_user
      assert_equal false, callback_registrar
    end
  end

  def test_cancel_redirects_to_root
    controller = Sso::TaraController.new
    controller.request = ActionController::TestRequest.create({})
    controller.response = ActionDispatch::TestResponse.create
    
    redirect_path = nil
    controller.define_singleton_method(:root_path) { '/' }
    controller.define_singleton_method(:redirect_to) do |path, options = {}|
      redirect_path = path
    end
    controller.define_singleton_method(:t) { |key| "Sign in cancelled" }
    
    controller.send(:cancel)
    assert_equal '/', redirect_path
  end

  def test_show_error_redirects_to_registrar_sign_in
    controller = Sso::TaraController.new
    controller.request = ActionController::TestRequest.create({})
    controller.response = ActionDispatch::TestResponse.create
    
    redirect_path = nil
    controller.define_singleton_method(:new_registrar_user_session_url) { '/registrar/sign_in' }
    controller.define_singleton_method(:redirect_to) do |path, options = {}|
      redirect_path = path
    end
    controller.define_singleton_method(:t) { |key| "No such user" }
    
    controller.send(:show_error, registrar: true)
    assert_equal '/registrar/sign_in', redirect_path
  end

  def test_show_error_redirects_to_registrant_sign_in
    controller = Sso::TaraController.new
    controller.request = ActionController::TestRequest.create({})
    controller.response = ActionDispatch::TestResponse.create
    
    redirect_path = nil
    controller.define_singleton_method(:new_registrant_user_session_url) { '/registrant/sign_in' }
    controller.define_singleton_method(:redirect_to) do |path, options = {}|
      redirect_path = path
    end
    controller.define_singleton_method(:t) { |key| "No such user" }
    
    controller.send(:show_error, registrar: false)
    assert_equal '/registrant/sign_in', redirect_path
  end

  def test_user_hash_returns_omniauth_data
    controller = Sso::TaraController.new
    controller.request = ActionController::TestRequest.create({})
    controller.request.env['omniauth.auth'] = { 'uid' => 'test_uid' }
    
    assert_equal({ 'uid' => 'test_uid' }, controller.send(:user_hash))
  end

  def test_user_hash_returns_nil_when_no_omniauth_data
    controller = Sso::TaraController.new
    controller.request = ActionController::TestRequest.create({})
    controller.request.env['omniauth.auth'] = nil
    
    assert_nil controller.send(:user_hash)
  end
end
