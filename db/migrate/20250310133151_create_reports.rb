class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports do |t|
      t.string :name
      t.text :description
      t.text :sql_query
      t.integer :created_by

      t.timestamps
    end
  end
end
