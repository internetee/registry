class AddUpDateValueToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :up_date, :timestamp
  end
end
