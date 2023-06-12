class ValidateNameNotNullInWhoisRecord < ActiveRecord::Migration[6.1]
  def up
    validate_check_constraint :whois_records, name: "whois_records_name_null"
    change_column_null :whois_records, :name, false
  end

  def down
    change_column_null :whois_records, :name, true
    remove_check_constraint :whois_records, name: "whois_records_name_null"
  end
end
