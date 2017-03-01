class RenameRegistrarUrlToWebsite < ActiveRecord::Migration
  def change
    rename_column :registrars, :url, :website
  end
end
