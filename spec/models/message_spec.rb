require 'rails_helper'

describe Message do
  context 'with invalid attribute' do
    before :all do
      @mssage = Message.new
    end

    it 'should not be valid' do
      @mssage.valid?
      @mssage.errors.full_messages.should match_array([
        "Body is missing"
      ])
    end

    it 'should not have any versions' do
      @mssage.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @mssage = Fabricate(:message)
    end

    it 'should be valid' do
      @mssage.valid?
      @mssage.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @mssage = Fabricate(:message)
      @mssage.valid?
      @mssage.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @mssage.versions.should == []
        @mssage.body = 'New body'
        @mssage.save
        @mssage.errors.full_messages.should match_array([])
        @mssage.versions.size.should == 1
      end
    end
  end
end
