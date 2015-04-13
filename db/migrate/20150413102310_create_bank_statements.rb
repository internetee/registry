class CreateBankStatements < ActiveRecord::Migration
  def change
    create_table :bank_statements do |t|
      # t.string :subject_code
      t.string :bank_code
      t.string :iban
      t.string :import_file_path
      t.datetime :queried_at

      t.timestamps
    end
  end
end
