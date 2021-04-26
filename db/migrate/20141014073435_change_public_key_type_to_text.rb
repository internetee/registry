class ChangePublicKeyTypeToText < ActiveRecord::Migration[6.0]
  def change
    change_column :dnskeys, :public_key, :text
  end
end
