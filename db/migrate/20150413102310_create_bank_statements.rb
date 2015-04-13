class CreateBankStatements < ActiveRecord::Migration
  def change
    create_table :bank_statements do |t|
      t.string :subject_code
      t.string :bank_code
      t.string :account_number
      t.date :date
      t.time :time
      t.string :import_file_path

      t.timestamps
    end
  end
end
