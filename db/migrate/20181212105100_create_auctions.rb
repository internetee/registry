class CreateAuctions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE auction_status AS ENUM (
        'open',
        'closed_without_winner',
        'closed_with_winner',
        'payment_received'
      );
    SQL

    create_table :auctions do |t|
      t.string :domain, null: false
      t.column :status, :auction_status, null: false
      t.uuid :uuid, default: 'gen_random_uuid()', null: false
      t.datetime :created_at, null: false
    end
  end

  def down
    execute <<-SQL
      DROP type auction_status;
    SQL

    drop_table :auctions
  end
end
