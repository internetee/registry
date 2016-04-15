require 'rails_helper'

describe BlockedDomain do
  context 'with no attributes' do
    before :all do
      @blocked_domain = BlockedDomain.new
    end

    it 'should have names array' do
      @blocked_domain.name.should == nil
    end
  end
end
