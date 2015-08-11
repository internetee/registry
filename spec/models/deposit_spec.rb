require 'rails_helper'

describe Deposit do
  context 'with invalid attribute' do
    before :all do
      @deposit = Deposit.new
    end

    it 'should not be valid' do
      @deposit.valid?
      @deposit.errors.full_messages.should match_array([
        "Registrar is missing"
      ])
    end

    it 'should have 0 amount' do
      @deposit.amount.should == 0
    end

    it 'should not be presisted' do
      @deposit.persisted?.should == false
    end

    it 'should replace comma with point for 0' do
      @deposit.amount = '0,0'
      @deposit.amount.should == 0.0
    end

    it 'should replace comma with points' do
      @deposit.amount = '10,11'
      @deposit.amount.should == 10.11
    end

    it 'should work with float as well' do
      @deposit.amount = 0.123
      @deposit.amount.should == 0.123
    end
  end
end
