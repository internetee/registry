class EnsureExpireAtOnReservedDomains < ActiveRecord::Migration[6.1]
  def up
    unless column_exists?(:reserved_domains, :expire_at)
      add_column :reserved_domains, :expire_at, :datetime, null: true
    end
  end

  def down
    remove_column :reserved_domains, :expire_at if column_exists?(:reserved_domains, :expire_at)
  end
end
