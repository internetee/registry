class AddNameNotNullConstraintInWhoisRecord < ActiveRecord::Migration[6.1]
  def change
    add_check_constraint :whois_records, "name IS NOT NULL", name: "whois_records_name_null", validate: false
  end
end
