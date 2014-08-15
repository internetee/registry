class AddAuthInfoToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :auth_info, :string
  end
end
