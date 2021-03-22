require 'test_helper'

class MassActionTest < ActiveSupport::TestCase
  setup do
    @csv_valid = Rails.root.join('test', 'fixtures', 'files', 'mass_actions', 'valid_mass_force_delete_list.csv').to_s
    @csv_invalid = Rails.root.join('test', 'fixtures', 'files', 'mass_actions', 'invalid_mass_force_delete_list.csv').to_s
  end

  def test_mass_action_procces_with_valid_data     
    assert MassAction.process("force_delete", @csv_valid)                       
  end

  def test_mass_action_proccess_with_invalid_data
    assert_not MassAction.process("force_delete", @csv_invalid) 
  end

  def test_mass_action_invalid_attributes
    assert_not MassAction.process("force_restart", @csv_valid)
  end
end