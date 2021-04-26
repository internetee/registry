class CreateActions < ActiveRecord::Migration[6.0]
  def change
    create_table :actions do |t|
      t.belongs_to :user, foreign_key: true
      t.string :operation
      t.datetime :created_at
    end
  end
end