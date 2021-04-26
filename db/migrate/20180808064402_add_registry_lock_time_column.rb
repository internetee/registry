class AddRegistryLockTimeColumn < ActiveRecord::Migration[6.0]
  def change
    change_table(:domains) do |t|
      t.column :locked_by_registrant_at, :datetime, null: true
    end
  end
end
