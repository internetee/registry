require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
  # setup do
  #   @domain = domains(:shop)
  #   @domain.apply_registry_lock(extensions_prohibited: false)
  # end
  #
  # def test_if_obj_and_extensions_prohibited_enabled
  #   ENV['obj_and_extensions_prohibited'] = 'true'
  #
  #   assert Feature.obj_and_extensions_statuses_enabled?
  #
  #   statuses = DomainStatus.admin_statuses
  #   assert statuses.include? DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED
  # end
  #
  # def test_if_obj_and_extensions_prohibited_is_nil
  #   ENV['obj_and_extensions_prohibited'] = nil
  #
  #   assert_not Feature.obj_and_extensions_statuses_enabled?
  #
  #   statuses = DomainStatus.admin_statuses
  #   assert_not statuses.include? DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED
  # end
  #
  # def test_if_obj_and_extensions_prohibited_is_false
  #   ENV['obj_and_extensions_prohibited'] = 'false'
  #
  #   assert_not Feature.obj_and_extensions_statuses_enabled?
  #
  #   statuses = DomainStatus.admin_statuses
  #   assert_not statuses.include? DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED
  # end
  #
  # def test_if_enable_lock_domain_with_new_statuses_is_nil
  #   ENV['enable_lock_domain_with_new_statuses'] = nil
  #
  #   assert_not Feature.enable_lock_domain_with_new_statuses?
  #
  #   assert_equal @domain.statuses, ["serverObjUpdateProhibited", "serverDeleteProhibited", "serverTransferProhibited"]
  #   assert @domain.locked_by_registrant?
  # end
  #
  # def test_if_enable_lock_domain_with_new_statuses_is_false
  #   ENV['enable_lock_domain_with_new_statuses'] = 'false'
  #
  #   assert_not Feature.enable_lock_domain_with_new_statuses?
  #
  #   assert_equal @domain.statuses, ["serverObjUpdateProhibited", "serverDeleteProhibited", "serverTransferProhibited"]
  #   assert @domain.locked_by_registrant?
  # end
end
