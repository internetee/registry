class AddUniqueConstraintToContactsCode < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE contacts ADD CONSTRAINT unique_contact_code UNIQUE (code)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE contacts DROP CONSTRAINT unique_contact_code
    SQL
  end
end
