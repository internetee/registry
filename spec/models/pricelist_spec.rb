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
        "Category is missing", 
        "Duration is missing", 
        "Operation category is missing"
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

    it 'should not have name' do
      @pricelist.name.should == ' '
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

    it 'should have name' do
      @pricelist.name.should == 'new .ee'
    end

    it 'should have one version' do
      with_versioning do
        @pricelist.versions.reload.should == []
        @pricelist.price = 11
        @pricelist.save
        @pricelist.errors.full_messages.should match_array([])
        @pricelist.versions.size.should == 1
      end
    end
  end
end
