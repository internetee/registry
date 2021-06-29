class CreateValidationEvents < ActiveRecord::Migration[6.1]

  def up
    execute <<-SQL
      CREATE TYPE validation_type AS ENUM ('email_validation', 'manual_force_delete');
    SQL

    create_table :validation_events do |t|
      t.jsonb :event_data
      t.boolean :result
      t.references :validation_eventable, polymorphic: true

      t.timestamps
    end

    add_column :validation_events, :event_type, :validation_type
    add_index :validation_events, :event_type
  end

  def down
    remove_column :validation_events, :event_type
    execute <<-SQL
      DROP TYPE validation_type;
    SQL

    drop_table :validation_events
  end
end
