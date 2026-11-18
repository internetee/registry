class CreateDomainPendingNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :domain_pending_notifications do |t|
      t.references :domain, type: :integer, null: false, foreign_key: { on_delete: :cascade }
      t.string :kind, null: false
      t.string :recipients, array: true, null: false, default: []
      t.datetime :created_at, null: false
    end
  end
end
