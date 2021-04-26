class RemoveDomainStatusField < ActiveRecord::Migration[6.0]
  def change
    remove_column :domains, :status
  end
end
