class AddUniqueIndexToWhoisRecordsDomainId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  INDEX = 'index_whois_records_on_domain_id'.freeze
  UNIQUE_INDEX = 'index_whois_records_on_domain_id_unique'.freeze

  def up
    # A failed concurrent build leaves an invalid index behind, start over in that case
    remove_index :whois_records, name: UNIQUE_INDEX, algorithm: :concurrently, if_exists: true

    # Unique index cannot be built with duplicates and data is not deleted by migrations
    duplicates = select_value(<<~SQL).to_i
      SELECT count(*) FROM (
        SELECT domain_id FROM whois_records
        WHERE domain_id IS NOT NULL GROUP BY domain_id HAVING count(*) > 1
      ) duplicated
    SQL
    if duplicates.positive?
      raise "#{duplicates} domains have more than one whois record, " \
            'run `DRY_RUN=false rake whois:remove_registry_duplicates` first'
    end

    add_index :whois_records, :domain_id, unique: true, name: UNIQUE_INDEX, algorithm: :concurrently
    remove_index :whois_records, name: INDEX, algorithm: :concurrently
    rename_index :whois_records, UNIQUE_INDEX, INDEX
  end

  def down
    add_index :whois_records, :domain_id, name: UNIQUE_INDEX, algorithm: :concurrently
    remove_index :whois_records, name: INDEX, algorithm: :concurrently
    rename_index :whois_records, UNIQUE_INDEX, INDEX
  end
end
