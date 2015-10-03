class AddUpdatedToken < ActiveRecord::Migration
  def change
    add_column :contacts, :legacy_ident_updated_at, :datetime
  end
end
