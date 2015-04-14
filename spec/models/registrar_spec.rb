require 'rails_helper'

describe Registrar do
  it { should have_many(:domains) }
  it { should have_many(:api_users) }
  it { should have_many(:messages) }

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
        'Reg no is missing'
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
      @registrar.code.should =~ /registrar/
    end

    it 'should not be able to change code' do
      @registrar.code = 'not-updated'
      @registrar.code.should =~ /registrar/
    end

    it 'should automatically add next code if original is taken' do
      @registrar = Fabricate(:registrar, name: 'uniq')
      @registrar.name = 'New name'
      @registrar.code.should == 'uniq'
      @registrar.save

      @new_registrar = Fabricate.build(:registrar, name: 'uniq')
      @new_registrar.valid?
      @new_registrar.errors.full_messages.should == []
      @new_registrar.code.should == 'uniq1'
    end

    it 'should be able to issue a prepayment invoice' do
      Fabricate(:registrar, name: 'EIS', reg_no: '90010019')
      @registrar.issue_prepayment_invoice(200, 'add some money')
      @registrar.invoices.count.should == 1
      i = @registrar.invoices.first
      i.sum.should == BigDecimal.new('240.0')
      i.description.should == 'add some money'
    end
  end
end
