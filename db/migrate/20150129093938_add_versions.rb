class AddVersions < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? 'versions'
      rename_table :versions, :depricated_versions
    end

    create_table :versions do |t|
      t.text :depricated_table_but_somehow_paper_trail_tests_fails_without_it
    end
  end
end
