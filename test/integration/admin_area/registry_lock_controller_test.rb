require 'test_helper'

class AdminAreaRegistryLockControllerTest < ApplicationIntegrationTest
  setup do
    WebMock.allow_net_connect!
    sign_in users(:admin)
    
    @domain = domains(:airport)
  end

  def test_destroy_successfully_removes_registry_lock
    @domain.apply_registry_lock(extensions_prohibited: false)
    assert @domain.locked_by_registrant?
    
    delete admin_domain_registry_lock_path(@domain)
    
    assert_redirected_to edit_admin_domain_path(@domain)
    assert_equal I18n.t('admin.domains.registry_lock.destroy.success'), flash[:notice]
    
    @domain.reload
    refute @domain.locked_by_registrant?
  end

  def test_destroy_fails_when_domain_cannot_be_unlocked
    refute @domain.locked_by_registrant?
    
    delete admin_domain_registry_lock_path(@domain)
    
    assert_redirected_to edit_admin_domain_path(@domain)
    assert_equal I18n.t('admin.domains.registry_lock.destroy.error'), flash[:alert]
    
    @domain.reload
    refute @domain.locked_by_registrant?
  end

  def test_destroy_fails_when_domain_has_admin_set_statuses
    @domain.statuses = [
      DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED,
      DomainStatus::SERVER_DELETE_PROHIBITED,
      DomainStatus::SERVER_TRANSFER_PROHIBITED
    ]
    @domain.save!
    
    delete admin_domain_registry_lock_path(@domain)
    
    assert_redirected_to edit_admin_domain_path(@domain)
    assert_equal I18n.t('admin.domains.registry_lock.destroy.error'), flash[:alert]
  end

  def test_destroy_requires_authorization
    sign_out users(:admin)
    sign_in users(:api_bestnames)
    
    @domain.apply_registry_lock(extensions_prohibited: false)
    
    delete admin_domain_registry_lock_path(@domain)
    
    assert_redirected_to new_admin_user_session_path
  end

  def test_destroy_requires_domain_management_permission
    user = users(:api_bestnames)
    user.roles = ['api_user']
    user.save!
    
    sign_out users(:admin)
    sign_in user
    
    @domain.apply_registry_lock(extensions_prohibited: false)
    
    delete admin_domain_registry_lock_path(@domain)
    
    assert_redirected_to new_admin_user_session_path
  end

  def test_destroy_with_nonexistent_domain
    assert_raises(ActiveRecord::RecordNotFound) do
      delete '/admin/domains/nonexistent-domain-id/registry_lock'
    end
  end


  def test_destroy_handles_domain_with_force_delete_status
    @domain.schedule_force_delete(type: :soft)
    @domain.reload
    @domain.apply_registry_lock(extensions_prohibited: false)
    
    assert @domain.force_delete_scheduled?
    assert @domain.locked_by_registrant?
    
    delete admin_domain_registry_lock_path(@domain)
    
    assert_redirected_to edit_admin_domain_path(@domain)
    assert_equal I18n.t('admin.domains.registry_lock.destroy.success'), flash[:notice]
    
    @domain.reload
    refute @domain.locked_by_registrant?
    assert @domain.force_delete_scheduled?
  end

  def test_destroy_creates_domain_version_record
    @domain.apply_registry_lock(extensions_prohibited: false)
    
    assert_difference '@domain.versions.count', 1 do
      delete admin_domain_registry_lock_path(@domain)
    end
    
    @domain.reload
    version = @domain.versions.last
    assert_equal 'update', version.event
    assert_not_nil version.whodunnit
  end

  private

  def admin_domain_registry_lock_path(domain)
    "/admin/domains/#{domain.id}/registry_lock"
  end
end
