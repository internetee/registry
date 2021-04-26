class RenameRegistrarUrlToWebsite < ActiveRecord::Migration[6.0]
  def change
    rename_column :registrars, :url, :website
  end
end
