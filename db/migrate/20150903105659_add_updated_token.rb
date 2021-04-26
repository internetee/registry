class AddUpdatedToken < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :legacy_ident_updated_at, :datetime
  end
end
