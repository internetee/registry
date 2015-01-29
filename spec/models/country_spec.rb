require 'rails_helper'

describe Country do
  before :all do 
    @epp_user = Fabricate(:country)
  end

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
  end

  context 'with valid attributes' do
    before :all do
      @country = Fabricate(:country)
    end

    it 'should be valid' do
      @country.valid?
      @country.errors.full_messages.should match_array([])
    end

    it 'should not have one version' do
      with_versioning do
        @country.versions.should == []
        @country.name = 'New name'
        @country.save
        @country.versions.size.should == 1
      end
    end
  end
end
