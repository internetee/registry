class CreateWhiteIpLog < ActiveRecord::Migration
  def change
    create_table :log_white_ips do |t|
      t.string   "item_type",      null: false
      t.integer  "item_id",        null: false
      t.string   "event",          null: false
      t.string   "whodunnit"
      t.json     "object"
      t.json     "object_changes"
      t.datetime "created_at"
      t.string   "session"
      t.json     "children"
    end

    add_column :white_ips, :creator_str, :string
    add_column :white_ips, :updator_str, :string
  end
end
