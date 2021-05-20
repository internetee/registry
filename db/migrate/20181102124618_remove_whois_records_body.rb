class RemoveWhoisRecordsBody < ActiveRecord::Migration[5.2]
  def up
    # remove_column :whois_records, :body
  end

  def down
    # add_column :whois_records, :body, :text
  end
end
