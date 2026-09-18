class AddSubjectToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :users, :subject, :string
    add_index :users, :subject, algorithm: :concurrently
    add_index :users, %i[registrar_id subject],
              unique: true,
              where: "subject IS NOT NULL AND subject != ''",
              algorithm: :concurrently
  end
end
