class CreateNameserversCache < ActiveRecord::Migration
  def up
    create_table :cached_nameservers, id: false do |t|
      t.string :hostname
      t.string :ipv4
      t.string :ipv6
    end
    add_index :cached_nameservers, [:hostname, :ipv4, :ipv6], unique: true

    execute <<-SQL
      INSERT INTO cached_nameservers (
        SELECT ns.hostname, ns.ipv4, ns.ipv6 FROM nameservers ns GROUP BY ns.hostname, ns.ipv4, ns.ipv6
      );
    SQL
  end

  def down
    drop_table :cached_nameservers
  end
end
