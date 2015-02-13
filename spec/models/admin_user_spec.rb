require 'rails_helper'
require 'cancan/matchers'

describe AdminUser do
  context 'with invalid attribute' do
    before :all do
      @user = AdminUser.new
    end

    it 'should not be valid' do
      @user.valid?
      @user.errors.full_messages.should match_array([
        "Country code is missing",
        "Email Email is missing",
        "Password Password is missing",
        "Username Username is missing"
      ])
    end

    it 'should not have any versions' do
      @user.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @user = Fabricate(:admin_user)
    end

    it 'should be valid' do
      @user.valid?
      @user.errors.full_messages.should match_array([])
    end

    # it 'should be valid twice' do
      # @user = Fabricate(:admin_user)
      # @user.valid?
      # @user.errors.full_messages.should match_array([])
    # end

    # it 'should have one version' do
      # with_versioning do
        # @user.versions.should == []
        # @user.zip = 'New zip'
        # @user.save
        # @user.errors.full_messages.should match_array([])
        # @user.versions.size.should == 1
      # end
    # end
  end

  # describe 'abilities' do
    # subject(:ability) { Ability.new(user) }
    # let(:user) { nil }

    # context 'when user is admin' do
      # let(:user) { Fabricate(:admin_user) }

      # it { should be_able_to(:manage, Domain.new) }
      # it { should be_able_to(:manage, Contact.new) }
      # it { should be_able_to(:manage, Registrar.new) }
      # it { should be_able_to(:manage, Setting.new) }
      # it { should be_able_to(:manage, ZonefileSetting.new) }
      # it { should be_able_to(:manage, DomainVersion.new) }
      # it { should be_able_to(:manage, User.new) }
      # it { should be_able_to(:manage, ApiUser.new) }
      # it { should be_able_to(:manage, Keyrelay.new) }
      # it { should be_able_to(:manage, LegalDocument.new) }
      # it { should be_able_to(:read, ApiLog::EppLog.new) }
      # it { should be_able_to(:read, ApiLog::ReppLog.new) }
      # it { should be_able_to(:index, :delayed_job) }
      # it { should be_able_to(:create, :zonefile) }
      # it { should be_able_to(:access, :settings_menu) }
    # end

    # context 'when user is customer service' do
      # let(:user) { Fabricate(:user, roles: ['customer_service']) }

      # it { should be_able_to(:manage, Domain.new) }
      # it { should be_able_to(:manage, Contact.new) }
      # it { should be_able_to(:manage, Registrar.new) }
      # it { should_not be_able_to(:manage, Setting.new) }
      # it { should_not be_able_to(:manage, ZonefileSetting.new) }
      # it { should_not be_able_to(:manage, DomainVersion.new) }
      # it { should_not be_able_to(:manage, User.new) }
      # it { should_not be_able_to(:manage, ApiUser.new) }
      # it { should_not be_able_to(:manage, LegalDocument.new) }
      # it { should_not be_able_to(:read, ApiLog::EppLog.new) }
      # it { should_not be_able_to(:read, ApiLog::ReppLog.new) }
      # it { should_not be_able_to(:index, :delayed_job) }
      # it { should_not be_able_to(:create, :zonefile) }
      # it { should_not be_able_to(:access, :settings_menu) }
    # end
  # end
end
