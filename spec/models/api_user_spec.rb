require 'rails_helper'

RSpec.describe ApiUser do
  context 'class methods' do
    before do
      Fabricate(:api_user, identity_code: '')
      Fabricate(:api_user, identity_code: 14212128025)
    end

    it 'should return all api users with given identity code' do
      ApiUser.all_by_identity_code('14212128025').size.should == 1
      ApiUser.all_by_identity_code(14212128025).size.should == 1
    end

    it 'should not return any api user with blank identity code' do
      ApiUser.all_by_identity_code('').size.should == 0
    end
  end

  context 'with invalid attribute' do
    before :all do
      @api_user = ApiUser.new
    end

    it 'should not be valid' do
      @api_user.valid?
      @api_user.errors.full_messages.should match_array([
        "Password Password is missing",
        "Password is too short (minimum is #{ApiUser.min_password_length} characters)",
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

  describe '::min_password_length', db: false do
    it 'returns minimum password length' do
      expect(described_class.min_password_length).to eq(6)
    end
  end
end
