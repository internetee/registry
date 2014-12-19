require 'rails_helper'
require 'cancan/matchers'

describe User do
  it { should belong_to(:role) }

  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'when user is admin' do
      let(:user) { Fabricate(:user) }

      it { should be_able_to(:manage, Domain.new) }
      it { should be_able_to(:manage, Contact.new) }
      it { should be_able_to(:manage, Registrar.new) }
      it { should be_able_to(:manage, Setting.new) }
      it { should be_able_to(:manage, ZonefileSetting.new) }
      it { should be_able_to(:manage, DomainVersion.new) }
      it { should be_able_to(:manage, User.new) }
      it { should be_able_to(:manage, EppUser.new) }
      it { should be_able_to(:manage, Keyrelay.new) }
      it { should be_able_to(:index, :delayed_job) }
      it { should be_able_to(:create, :zonefile) }
      it { should be_able_to(:access, :settings_menu) }
    end

    context 'when user is customer service' do
      let(:user) { Fabricate(:user, role: Role.new(code: 'customer_service')) }

      it { should be_able_to(:manage, Domain.new) }
      it { should be_able_to(:manage, Contact.new) }
      it { should be_able_to(:manage, Registrar.new) }
      it { should_not be_able_to(:manage, Setting.new) }
      it { should_not be_able_to(:manage, ZonefileSetting.new) }
      it { should_not be_able_to(:manage, DomainVersion.new) }
      it { should_not be_able_to(:manage, User.new) }
      it { should_not be_able_to(:manage, EppUser.new) }
      it { should_not be_able_to(:index, :delayed_job) }
      it { should_not be_able_to(:create, :zonefile) }
      it { should_not be_able_to(:access, :settings_menu) }
    end
  end
end
