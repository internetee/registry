require 'rails_helper'

describe BankStatement do
  context 'with invalid attribute' do
    before :all do
      @bank_statement = BankStatement.new
    end

    it 'should not be valid' do
      @bank_statement.valid?
      @bank_statement.errors.full_messages.should match_array([
        "Bank code is missing",
        "Iban is missing"
      ])
    end

    it 'should not have any versions' do
      @bank_statement.versions.should == []
    end
  end

  context 'with valid attributes' do
    before do
      @bank_statement = create(:bank_statement)
    end

    it 'should be valid' do
      @bank_statement.valid?
      @bank_statement.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @bank_statement = create(:bank_statement)
      @bank_statement.valid?
      @bank_statement.errors.full_messages.should match_array([])
    end

    it 'should not bind transactions with invalid match data' do
      r = create(:registrar, reference_no: 'RF7086666663')

      create(:account, registrar: r, account_type: 'cash', balance: 0)

      r.issue_prepayment_invoice(200, 'add some money')

      bs = create(:bank_statement, bank_transactions: [
        create(:bank_transaction, {
          sum: 240.0, # with vat
          reference_no: 'RF7086666662',
          description: 'Invoice no. 1'
        }),
        create(:bank_transaction, {
          sum: 240.0,
          reference_no: 'RF7086666663',
          description: 'Invoice no. 4948934'
        })
      ])

      bs.bank_transactions.count.should == 4

      AccountActivity.count.should == 0
      bs.bind_invoices

      AccountActivity.count.should == 0

      r.cash_account.balance.should == 0.0

      bs.bank_transactions.unbinded.count.should == 4
      bs.not_binded?.should == true
    end

    it 'should have one version' do
      with_versioning do
        @bank_statement.versions.should == []
        @bank_statement.bank_code = 'new_code'
        @bank_statement.save
        @bank_statement.errors.full_messages.should match_array([])
        @bank_statement.versions.size.should == 1
      end
    end
  end
end
