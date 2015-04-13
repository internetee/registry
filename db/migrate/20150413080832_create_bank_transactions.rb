class CreateBankTransactions < ActiveRecord::Migration
  def change
    create_table :bank_transactions do |t|
      t.integer :bank_statement_id
      t.string :subject_code
      # record_code # kirjetunnus - ei kasuta? # impordime ainult tehingud nagunii
      t.string :bank_reference # panga viide
      t.string :tr_code # tehingu liik (MK / MV)
      t.string :iban # own bank account no.
      t.string :currency
      t.string :other_party_bank
      t.string :other_party_name
      t.string :doc_no
      t.string :description
      #tr_type # C/D # impordime ainult cre nagunii
      t.decimal :amount
      t.string :reference_no

      t.timestamps
    end
  end
end
