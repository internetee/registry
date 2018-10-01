require 'rails_helper'

describe BankTransaction do
  context 'with invalid attribute' do
    before :all do
      @bank_transaction = BankTransaction.new
    end

    it 'should not be valid' do
      @bank_transaction.valid?
      @bank_transaction.errors.full_messages.should match_array([
      ])
    end

    it 'should not have any versions' do
      @bank_transaction.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @bank_transaction = create(:bank_transaction)
      create(:registrar)
    end

    it 'should be valid' do
      @bank_transaction.valid?
      @bank_transaction.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @bank_transaction = create(:bank_statement)
      @bank_transaction.valid?
      @bank_transaction.errors.full_messages.should match_array([])
    end

    it 'should not bind transaction with mismatching sums' do
      r = create(:registrar)
      invoice = r.issue_prepayment_invoice(200, 'add some money')

      bt = create(:bank_transaction, { sum: 10 })
      bt.bind_invoice(invoice.number)

      bt.errors.full_messages.should match_array(["Invoice and transaction sums do not match"])
    end

    it 'should not bind transaction with cancelled invoice' do
      r = create(:registrar)
      invoice = r.issue_prepayment_invoice(200, 'add some money')
      invoice.cancel

      bt = create(:bank_transaction, { sum: 240 })
      bt.bind_invoice(invoice.number)

      bt.errors.full_messages.should match_array(["Cannot bind cancelled invoice"])
    end

    it 'should have one version' do
      with_versioning do
        @bank_transaction.versions.should == []
        @bank_transaction.bank_reference = '123'
        @bank_transaction.save
        @bank_transaction.errors.full_messages.should match_array([])
        @bank_transaction.versions.size.should == 1
      end
    end
  end
end
