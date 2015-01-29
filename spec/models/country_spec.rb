require 'rails_helper'

describe Country do
  context 'about class' do
    it 'should have versioning enabled?' do
      Country.paper_trail_enabled_for_model?.should == true
    end

    it 'should have custom log prexied table name for versions table' do
      CountryVersion.table_name.should == 'log_countries'
    end
  end

  context 'with invalid attribute' do
    before :all do
      @country = Country.new
    end

    it 'should not be valid' do
      @country.valid?
      @country.errors.full_messages.should match_array([
        "Name is missing"
      ])
    end

    it 'should not have any versions' do
      @country.versions.should == []
    end

    it 'should not have any creator' do
      @country.creator_str.should == nil
    end

    it 'should not have any updater' do
      @country.updator_str.should == nil
    end
  end

  context 'with valid attributes' do
    before :all do
      @country = Fabricate(:country)
    end

    it 'should be valid' do
      @country.valid?
      @country.errors.full_messages.should match_array([])
    end

    it 'should not have a version' do
      with_versioning do
        @country.versions.should == []
        @country.name = 'New name'
        @country.save
        @country.versions.size.should == 1
      end
    end

    it 'should have creator' do
      PaperTrail.whodunnit = 'test-user'

      with_versioning do
        @country = Fabricate(:country)
        @country.name = 'Updated name'
        @country.save
        @country.creator_str.should == 'test-user'
        @country.updator_str.should == 'test-user'
      end
    end

    it 'should have creator' do
      PaperTrail.whodunnit = 'test-user-2'

      with_versioning do
        @country.name = 'Updated name'
        @country.save
        @country.updator_str.should == 'test-user-2'
        @country.creator_str.should == nil # Factory does not have it
      end
    end
  end
end
