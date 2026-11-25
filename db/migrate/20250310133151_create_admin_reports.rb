class CreateAdminReports < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_reports do |t|
      t.string :name
      t.text :description
      t.text :sql_query
      t.json :parameters
      t.integer :created_by

      t.timestamps
    end
  end
end
