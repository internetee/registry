require 'rails_helper'

describe Pricelist do
  before :all do
  end

  context 'about class' do
  end

  context 'with invalid attribute' do
    before :all do
      @pricelist = Pricelist.new
    end

    it 'should not be valid' do
      @pricelist.valid?
      @pricelist.errors.full_messages.should match_array([
        "Valid from is missing",
        "Active until is missing",
        "Category is missing"
      ])
    end

    it 'should not have creator' do
      @pricelist.creator.should == nil
    end

    it 'should not have updater' do
      @pricelist.updator.should == nil
    end

    it 'should not have any versions' do
      @pricelist.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @pricelist = Fabricate(:pricelist)
    end

    it 'should be valid' do
      @pricelist.valid?
      @pricelist.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @pricelist = Fabricate(:pricelist)
      @pricelist.valid?
      @pricelist.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @pricelist.versions.reload.should == []
        @pricelist.name = 'New name'
        @pricelist.save
        @pricelist.errors.full_messages.should match_array([])
        @pricelist.versions.size.should == 1
      end
    end
  end
end
