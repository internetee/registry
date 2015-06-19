require 'rails_helper'
require 'cancan/matchers'

describe AdminUser do
  context 'with invalid attribute' do
    before :all do
      @admin_user = AdminUser.new
    end

    it 'should not be valid' do
      @admin_user.valid?
      @admin_user.errors.full_messages.should match_array([
        "Country code is missing",
        "Email Email is missing",
        "Email Email is missing",
        "Password Password is missing",
        "Password Password is missing",
        "Password confirmation is missing",
        "Roles is missing",
        "Username Username is missing"
      ])
    end

    it 'should not have any versions' do
      @admin_user.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @admin_user = Fabricate(:admin_user)
    end

    it 'should be valid' do
      @admin_user.valid?
      @admin_user.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @admin_user = Fabricate(:admin_user)
      @admin_user.valid?
      @admin_user.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @admin_user.versions.should == []
        @admin_user.updated_at = Time.zone.now
        @admin_user.save
        @admin_user.errors.full_messages.should match_array([])
        @admin_user.versions.size.should == 1
      end
    end

    it 'should require password confirmation when changing password' do
      @admin_user.valid?.should == true
      @admin_user.password = 'not confirmed'
      @admin_user.valid?
      @admin_user.errors.full_messages.should match_array([
        "Password confirmation doesn't match Password"
      ])
    end
  end
end
