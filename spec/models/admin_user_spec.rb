require 'rails_helper'

RSpec.describe AdminUser do
  context 'with invalid attribute' do
    before do
      @admin_user = described_class.new
    end

    it 'should not have any versions' do
      @admin_user.versions.should == []
    end
  end

  context 'with valid attributes' do
    before do
      @admin_user = Fabricate(:admin_user)
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
      @admin_user.errors.full_messages.should match_array(["Password confirmation doesn't match Password"])
    end
  end

  describe '::min_password_length' do
    it 'returns minimum password length' do
      expect(described_class.min_password_length).to eq(8)
    end
  end
end
