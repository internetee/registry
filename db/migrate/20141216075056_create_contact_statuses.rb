class CreateContactStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_statuses do |t|
      t.string :value
      t.string :description
      t.belongs_to :contact
      t.timestamps
    end
  end
end
