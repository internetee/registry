class AddUpDateValueToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :up_date, :timestamp
  end
end
