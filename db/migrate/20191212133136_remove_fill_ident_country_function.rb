class RemoveFillIdentCountryFunction < ActiveRecord::Migration[5.0]
  def change
    execute <<~SQL
      DROP FUNCTION fill_ident_country();
    SQL
  end
end
