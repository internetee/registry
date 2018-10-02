class RemoveDomainStatusField < ActiveRecord::Migration
  def change
    remove_column :domains, :status
  end
end
