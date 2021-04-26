class AddAuthInfoToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :auth_info, :string
  end
end
