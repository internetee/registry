require 'application_system_test_case'

class AdminAreaBankStatementTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    travel_to Time.zone.parse('2010-07-05 00:30:00')
  end

  def test_import_statement
    assert_difference 'BankStatement.count', 1 do
      visit import_admin_bank_statements_path
      attach_file 'Th6 file', Rails.root.join('test', 'fixtures', 'files', 'bank_statement_test.txt').to_s
      click_link_or_button 'Save'
    end
  end
end
