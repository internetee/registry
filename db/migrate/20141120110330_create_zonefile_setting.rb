class CreateZonefileSetting < ActiveRecord::Migration
  def change
    create_table :zonefile_settings do |t|
      t.string :origin
      t.integer :ttl
      t.integer :refresh
      t.integer :retry
      t.integer :expire
      t.integer :minimum_ttl
      t.string :email

      t.timestamps
    end

    # rubocop: disable Style/NumericLiterals
    ZonefileSetting.create({
      origin: 'ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee'
    })
  end
end


