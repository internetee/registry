class AddNewValueToEventType < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE validation_type ADD VALUE 'nameserver_validation' AFTER 'manual_force_delete';
    SQL
  end
end
