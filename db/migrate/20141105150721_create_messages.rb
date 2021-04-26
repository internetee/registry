class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.integer :registrar_id
      t.string :body
      t.string :attached_obj_type
      t.string :attached_obj_id
      t.boolean :queued

      t.timestamps
    end
  end
end
