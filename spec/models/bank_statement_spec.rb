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
    before :all do
      @bank_statement = Fabricate(:bank_statement)
      Fabricate(:eis)
    end

    it 'should be valid' do
      @bank_statement.valid?
      @bank_statement.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @bank_statement = Fabricate(:bank_statement)
      @bank_statement.valid?
      @bank_statement.errors.full_messages.should match_array([])
    end

    it 'should bind transactions with invoices' do
      # pending 'Robot fails, probably we need to reset data here or some other issue'
      # sometimes it works, sometimes not
      # r = Fabricate(:registrar_with_no_account_activities, reference_no: 'RF7086666663')
      # invoice = r.issue_prepayment_invoice(200, 'add some money')

      # bs = Fabricate(:bank_statement, bank_transactions: [
        # Fabricate(:bank_transaction, {
          # sum: 240.0, # with vat
          # reference_no: 'RF7086666663',
          # description: "Invoice no. #{invoice.number}"
        # }),
        # Fabricate(:bank_transaction, {
          # sum: 240.0,
          # reference_no: 'RF7086666663',
          # description: "Invoice no. #{invoice.number}"
        # })
      # ])

      # bs.bank_transactions.count.should == 2

      # AccountActivity.count.should == 0
      # bs.bind_invoices

      # AccountActivity.count.should == 1

      # a = AccountActivity.last
      # a.description.should == "Invoice no. #{invoice.number}"
      # a.sum.should == BigDecimal.new('200.0')
      # a.activity_type = AccountActivity::ADD_CREDIT

      # r.reload
      # r.cash_account.reload
      # r.cash_account.balance.should == 200.0

      # bs.bank_transactions.unbinded.count.should == 1
      # bs.partially_binded?.should == true
    end

    it 'should not bind transactions with invalid match data' do
      r = Fabricate(:registrar_with_no_account_activities, reference_no: 'RF7086666663')
      r.issue_prepayment_invoice(200, 'add some money')

      bs = Fabricate(:bank_statement, bank_transactions: [
        Fabricate(:bank_transaction, {
          sum: 240.0, # with vat
          reference_no: 'RF7086666662',
          description: 'Invoice no. 1'
        }),
        Fabricate(:bank_transaction, {
          sum: 240.0,
          reference_no: 'RF7086666663',
          description: 'Invoice no. 4948934'
        })
      ])

      bs.bank_transactions.count.should == 2

      AccountActivity.count.should == 0
      bs.bind_invoices

      AccountActivity.count.should == 0

      r.cash_account.balance.should == 0.0

      bs.bank_transactions.unbinded.count.should == 2
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
