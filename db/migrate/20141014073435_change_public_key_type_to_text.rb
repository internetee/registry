class ChangePublicKeyTypeToText < ActiveRecord::Migration
  def change
    change_column :dnskeys, :public_key, :text
  end
end
