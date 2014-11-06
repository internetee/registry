class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :registrar_id
      t.string :body
      t.string :object_type
      t.string :object

      t.timestamps
    end
  end
end
