require 'application_system_test_case'
require 'test_helper'

class AdminAreaMassActionsForceDeleteTest < ApplicationSystemTestCase
  def setup
    sign_in users(:admin)
  end

  def test_processes_uploaded_valid_csv
    visit admin_mass_actions_path

    attach_file('entry_list', Rails.root.join('test', 'fixtures', 'files', 'mass_actions', 'valid_mass_force_delete_list.csv').to_s)
    click_link_or_button 'Start force delete process'
    assert_text 'force_delete completed for ["shop.test", "airport.test", "library.test"]. Failed: ["nonexistant.test"]'
  end

  def test_processes_uploaded_invalid_csv
    visit admin_mass_actions_path

    attach_file(:entry_list, Rails.root.join('test', 'fixtures', 'files', 'mass_actions', 'invalid_mass_force_delete_list.csv').to_s)
    click_link_or_button 'Start force delete process'
    assert_text 'Dataset integrity validation failed for force_delete'
  end
end
