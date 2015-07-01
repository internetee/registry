require 'rails_helper'

describe BlockedDomain do
  context 'with no attributes' do
    before :all do
      @blocked_domain = BlockedDomain.new
    end

    it 'should have names array' do
      @blocked_domain.names.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @blocked_domain = Fabricate(:blocked_domain)
    end

    it 'should be valid' do
      @blocked_domain.valid?
      @blocked_domain.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @blocked_domain.versions.should == []
        @blocked_domain.names = ['bla.ee']
        @blocked_domain.save
        @blocked_domain.errors.full_messages.should match_array([])
        @blocked_domain.versions.size.should == 1
      end
    end
  end
end
