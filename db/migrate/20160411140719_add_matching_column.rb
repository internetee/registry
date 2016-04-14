class AddMatchingColumn < ActiveRecord::Migration

  def change
    tables = [:log_domains, :log_contacts]

    tables.each do |table|
      add_column table, :uuid, :text
    end
  end


end
