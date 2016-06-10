class CreateDirectos < ActiveRecord::Migration
  def change
    create_table :directos do |t|
      t.belongs_to :item, index: true, polymorphic: true
      t.json :response

      t.timestamps null: false
    end
  end
end
