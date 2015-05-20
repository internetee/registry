require 'rails_helper'

describe ApiUser do
  it { should belong_to(:registrar) }

  context 'with invalid attribute' do
    before :all do
      @api_user = ApiUser.new
    end

    it 'should not be valid' do
      @api_user.valid?
      @api_user.errors.full_messages.should match_array([
        "Password Password is missing",
        "Registrar Registrar is missing",
        "Username Username is missing",
        "Roles is missing"
      ])
    end

    it 'should not have any versions' do
      @api_user.versions.should == []
    end

    it 'should be active by default' do
      @api_user.active.should == true
    end
  end

  context 'with valid attributes' do
    before :all do
      @api_user = Fabricate(:api_user)
    end

    it 'should be valid' do
      @api_user.valid?
      @api_user.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @api_user = Fabricate(:api_user)
      @api_user.valid?
      @api_user.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @api_user.versions.should == []
        @api_user.username = 'newusername'
        @api_user.save
        @api_user.errors.full_messages.should match_array([])
        @api_user.versions.size.should == 1
      end
    end
  end
end
