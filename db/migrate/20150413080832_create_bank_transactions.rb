class CreateBankTransactions < ActiveRecord::Migration
  def change
    create_table :bank_transactions do |t|
      t.integer :bank_statement_id
      # t.string :subject_code (VV)
      # record_code # kirjetunnus - ei kasuta? # impordime ainult tehingud nagunii
      t.string :bank_reference # panga viide
      # t.string :tr_code # tehingu liik (MK / MV)
      t.string :iban # own bank account no.
      t.string :currency
      t.string :buyer_bank_code
      t.string :buyer_iban
      t.string :buyer_name
      t.string :document_no
      t.string :description
      #tr_type # C/D # impordime ainult cre nagunii
      t.decimal :sum
      t.string :reference_no
      t.datetime :paid_at

      t.timestamps
    end
  end
end
