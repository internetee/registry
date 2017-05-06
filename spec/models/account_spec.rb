require 'rails_helper'

RSpec.describe Account do
  context 'with invalid attribute' do
    before :all do
      @account = Account.new
    end

    it 'should not be valid' do
      @account.valid?
      @account.errors.full_messages.should match_array(["Account type is missing"])
    end

    it 'should not have any versions' do
      @account.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @account = Fabricate(:account)
    end

    it 'should be valid' do
      @account.valid?
      @account.errors.full_messages.should match_array([])
      s = 0.0
      @account.activities.map { |x| s += x.sum }
      @account.balance.should == s
    end

    it 'should be valid twice' do
      @account = Fabricate(:account)
      @account.valid?
      @account.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @account.versions.should == []
        @account.account_type = 'new_type'
        @account.save
        @account.errors.full_messages.should match_array([])
        @account.versions.size.should == 1
      end
    end
  end

  describe 'registrar validation', db: false do
    subject(:account) { described_class.new }

    it 'rejects absent' do
      account.registrar = nil
      account.validate
      expect(account.errors).to have_key(:registrar)
    end
  end
end
