class AddChildrenToDomain < ActiveRecord::Migration[5.1]
  def change
    add_column :domains, :children, :json
  end
end
