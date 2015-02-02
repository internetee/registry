require 'rails_helper'

describe DomainTransfer do
  it { should belong_to(:domain) }

  context 'with invalid attribute' do
    before :all do
      @domain_transfer = DomainTransfer.new
    end

    it 'should not be valid' do
      @domain_transfer.valid?
      @domain_transfer.errors.full_messages.should match_array([
      ])
    end

    it 'should not have any versions' do
      @domain_transfer.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @domain_transfer = Fabricate(:domain_transfer)
    end

    it 'should be valid' do
      @domain_transfer.valid?
      @domain_transfer.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @domain_transfer = Fabricate(:domain_transfer)
      @domain_transfer.valid?
      @domain_transfer.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @domain_transfer.versions.should == []
        @domain_transfer.wait_until = 1.day.since
        @domain_transfer.save
        @domain_transfer.errors.full_messages.should match_array([])
        @domain_transfer.versions.size.should == 1
      end
    end
  end
end
