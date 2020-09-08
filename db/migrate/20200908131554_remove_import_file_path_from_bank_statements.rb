class RemoveImportFilePathFromBankStatements < ActiveRecord::Migration[6.0]
  def up
    remove_column :bank_statements, :import_file_path
  end

  def down
    add_column :bank_statements, :import_file_path, :string
  end
end
