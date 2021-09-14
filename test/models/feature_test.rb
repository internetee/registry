require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
  def test_if_obj_and_extensions_prohibited_enabled
    ENV['obj_and_extensions_prohibited'] = 'true'

    assert Feature.obj_and_extensions_statuses_enabled?

    statuses = DomainStatus.admin_statuses
    assert statuses.include? DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED
  end

  def test_if_obj_and_extensions_prohibited_is_nil
    ENV['obj_and_extensions_prohibited'] = nil

    assert_not Feature.obj_and_extensions_statuses_enabled?

    statuses = DomainStatus.admin_statuses
    assert_not statuses.include? DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED
  end

  def test_if_obj_and_extensions_prohibited_is_false
    ENV['obj_and_extensions_prohibited'] = 'false'

    assert_not Feature.obj_and_extensions_statuses_enabled?

    statuses = DomainStatus.admin_statuses
    assert_not statuses.include? DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED
  end
end
