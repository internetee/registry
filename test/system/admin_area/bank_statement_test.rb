require 'application_system_test_case'

class AdminAreaBankStatementTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    travel_to Time.zone.parse('2010-07-05 00:30:00')
  end

  def test_can_create_statement_manually
    visit admin_bank_statements_path
    click_link_or_button 'Add'
    click_link_or_button 'Save'
    assert_text 'Record created'
  end
end
