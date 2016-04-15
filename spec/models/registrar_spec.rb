require 'rails_helper'

describe Registrar do
  it { should have_many(:domains) }
  it { should have_many(:api_users) }
  it { should have_many(:messages) }
  it { should have_many(:white_ips) }

  context 'with invalid attribute' do
    before :all do
      @registrar = Registrar.new
    end

    it 'is not valid' do
      @registrar.valid?
      @registrar.errors.full_messages.should match_array([
        'Contact e-mail is missing',
        'Country code is missing',
        'Name is missing',
        'Reg no is missing',
        'Code is missing'
      ])
    end

    it 'returns an error with invalid email' do
      @registrar.email = 'bla'
      @registrar.billing_email = 'bla'

      @registrar.valid?
      @registrar.errors[:email].should == ['is invalid']
      @registrar.errors[:billing_email].should == ['is invalid']
    end

    it 'should not have valid code' do
      @registrar.code.should == nil
    end

    it 'should generate reference number' do
      @registrar.generate_iso_11649_reference_no
      @registrar.reference_no.should_not be_blank
      @registrar.reference_no.last(10).to_i.should_not == 0
    end

    it 'should not have priv contacts' do
      @registrar.priv_contacts.size.should == 0
    end
  end

  context 'with valid attributes' do
    before :all do
      @registrar = Fabricate(:registrar)
    end

    it 'should be valid' do
      @registrar.valid?
      @registrar.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @registrar = Fabricate(:registrar)
      @registrar.valid?
      @registrar.errors.full_messages.should match_array([])
    end

    it 'should have a cash account' do
      @registrar.cash_account.should_not be_nil
    end

    it 'should validates uniqueness of code' do
      registrar = Fabricate.build(:registrar, code: @registrar.code)
      registrar.valid?
      registrar.errors.full_messages.should match_array([
        'Code has already been taken'
      ])
    end

    it 'should remove blank from code' do
      registrar = Fabricate.build(:registrar, code: 'with blank')
      registrar.valid?
      registrar.errors.full_messages.should match_array([
      ])
      registrar.code.should == 'WITHBLANK'
    end

    it 'should remove colon from code' do
      registrar = Fabricate.build(:registrar, code: 'with colon:and:blank')
      registrar.valid?
      registrar.errors.full_messages.should match_array([
      ])
      registrar.code.should == 'WITHCOLONANDBLANK'
    end

    it 'should allow dot in code' do
      registrar = Fabricate.build(:registrar, code: 'with.dot')
      registrar.valid?
      registrar.errors.full_messages.should match_array([
      ])
      registrar.code.should == 'WITH.DOT'
    end

    it 'should have one version' do
      with_versioning do
        @registrar.versions.should == []
        @registrar.name = 'New name'
        @registrar.save
        @registrar.errors.full_messages.should match_array([])
        @registrar.versions.size.should == 1
      end
    end

    it 'should return full address' do
      @registrar.address.should == 'Street 999, Town, County, Postal'
    end

    it 'should have code' do
      @registrar.code.should =~ /REGISTRAR/
    end

    it 'should not be able to change code' do
      @registrar.code = 'not-updated'
      @registrar.code.should =~ /REGISTRAR/
    end

    it 'should be able to issue a prepayment invoice' do
      Setting.days_to_keep_invoices_active = 30
      Fabricate(:registrar, name: 'EIS', reg_no: '90010019')
      @registrar.issue_prepayment_invoice(200, 'add some money')
      @registrar.invoices.count.should == 1
      i = @registrar.invoices.first
      i.sum.should == BigDecimal.new('240.0')
      i.due_date.should be_within(0.1).of((Time.zone.now + 30.days).end_of_day)
      i.description.should == 'add some money'

      @registrar.issue_prepayment_invoice(200)
      i = @registrar.invoices.last
      i.description.should start_with "Order nr."
    end

    it 'should not allaw to use CID as code for leagcy reasons' do
      registrar = Fabricate.build(:registrar, code: 'CID')
      registrar.valid?
      registrar.errors.full_messages.should == ['Code is forbidden to use']
    end

    it 'should have priv contacts' do
      Fabricate(:contact, registrar: @registrar)
      @registrar.reload.priv_contacts.size.should == 1
    end

    it 'should not have priv contacts' do
      @registrar.priv_contacts.size.should == 0
    end

    it 'should credit and debit registrar cash account' do
      @registrar.credit!({ sum: 13.32, description: 'Add money' })
      @registrar.balance.should == BigDecimal.new('13.32')
      @registrar.cash_account.account_activities.count.should == 1
      a = @registrar.cash_account.account_activities.last
      a.description.should == 'Add money'
      a.sum.should == BigDecimal.new('13.32')
      a.log_pricelist_id.should == nil

      @registrar.debit!({ sum: 10.31, description: 'Remove money' })
      @registrar.balance.should == BigDecimal.new('3.01')
      @registrar.cash_account.account_activities.count.should == 2
      a = @registrar.cash_account.account_activities.last
      a.description.should == 'Remove money'
      a.sum.should == -BigDecimal.new('10.31')
    end
  end
end
