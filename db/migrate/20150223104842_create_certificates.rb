class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :api_user_id
      t.text :csr
      t.text :crt
      t.string :creator_str
      t.string :updator_str

      t.timestamps
    end

    create_table :log_certificates do |t|
      t.string "item_type", null: false
      t.integer "item_id", null: false
      t.string "event", null: false
      t.string "whodunnit"
      t.json "object"
      t.json "object_changes"
      t.datetime "created_at"
      t.string "session"
      t.json "children"
    end

    ApiUser.all.each do |x|
      x.certificates << Certificate.new(crt: x.crt, csr: x.csr)
    end
  end
end
