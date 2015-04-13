class CreateBanklinkTransactions < ActiveRecord::Migration
  def change
    create_table :banklink_transactions do |t|
      t.string :vk_service
      t.string :vk_version
      t.string :vk_snd_id
      t.string :vk_rec_id
      t.string :vk_stamp
      t.string :vk_t_no
      t.decimal :vk_amount
      t.string :vk_curr
      t.string :vk_rec_acc
      t.string :vk_rec_name
      t.string :vk_snd_acc
      t.string :vk_snd_name
      t.string :vk_ref
      t.string :vk_msg
      t.datetime :vk_t_datetime
      t.string :vk_mac
      t.string :vk_encoding
      t.string :vk_lang
      t.string :vk_auto

      t.timestamps
    end
  end
end
