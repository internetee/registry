class IndexDomainsOnName < ActiveRecord::Migration[6.0]
  def change
    add_index :domains, :name, unique: true
  end
end
