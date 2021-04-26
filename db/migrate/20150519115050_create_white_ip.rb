class CreateWhiteIp < ActiveRecord::Migration[6.0]
  def change
    create_table :white_ips do |t|
      t.integer :registrar_id
      t.string :ipv4
      t.string :ipv6
      t.string :interface
      t.timestamps
    end
  end
end
