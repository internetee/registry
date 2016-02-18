class IndexDomainStatuses < ActiveRecord::Migration
  def change
    add_index :domains, :statuses, using: :gin
  end
end
