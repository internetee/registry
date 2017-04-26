require 'rails_helper'

RSpec.describe Domain do
  before :example do
    Setting.ds_algorithm = 2
    Setting.ds_data_allowed = true
    Setting.ds_data_with_key_allowed = true
    Setting.key_data_allowed = true

    Setting.dnskeys_min_count = 0
    Setting.dnskeys_max_count = 9
    Setting.ns_min_count = 2
    Setting.ns_max_count = 11

    Setting.transfer_wait_time = 0

    Setting.admin_contacts_min_count = 1
    Setting.admin_contacts_max_count = 10
    Setting.tech_contacts_min_count = 0
    Setting.tech_contacts_max_count = 10

    Setting.client_side_status_editing_enabled = true

    Fabricate(:zone, origin: 'ee')
    Fabricate(:zone, origin: 'pri.ee')
    Fabricate(:zone, origin: 'med.ee')
    Fabricate(:zone, origin: 'fie.ee')
    Fabricate(:zone, origin: 'com.ee')
  end

  context 'with invalid attribute' do
    before :example do
      @domain = Domain.new
    end

    it 'should not be valid' do
      @domain.valid?
      @domain.errors.full_messages.should match_array([
        "Admin domain contacts Admin contacts count must be between 1-10",
        "Period Period is not a number",
        "Registrant Registrant is missing",
        "Registrar Registrar is missing"
      ])
    end

    it 'should not have any versions' do
      @domain.versions.should == []
    end

    it 'should not have whois body' do
      @domain.whois_record.should == nil
    end

    it 'should not be registrant update confirm ready' do
      @domain.registrant_update_confirmable?('123').should == false
    end

    it 'should not have pending update' do
      @domain.pending_update?.should == false
    end

    it 'should allow pending update' do
      @domain.pending_update_prohibited?.should == false
    end

    it 'should not have pending delete' do
      @domain.pending_delete?.should == false
    end

    it 'should allow pending delete' do
      @domain.pending_delete_prohibited?.should == false
    end
  end

  context 'with valid attributes' do
    before :example do
      @domain = Fabricate(:domain)
    end

    it 'should be valid' do
      @domain.valid?
      @domain.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @domain = Fabricate(:domain)
      @domain.valid?
      @domain.errors.full_messages.should match_array([])
    end

    it 'should validate uniqueness of tech contacts' do
      same_contact = Fabricate(:contact, code: 'same_contact')
      domain = Fabricate(:domain)
      domain.tech_contacts << same_contact
      domain.tech_contacts << same_contact
      domain.valid?
      domain.errors.full_messages.should match_array(["Tech domain contacts is invalid"])
    end

    it 'should validate uniqueness of tech contacts' do
      same_contact = Fabricate(:contact, code: 'same_contact')
      domain = Fabricate(:domain)
      domain.admin_contacts << same_contact
      domain.admin_contacts << same_contact
      domain.valid?
      domain.errors.full_messages.should match_array(["Admin domain contacts is invalid"])
    end

    it 'should have whois body by default' do
      @domain.whois_record.present?.should == true
    end

    it 'should have whois json by default' do
      @domain.whois_record.json.present?.should == true
    end

    it 'should not be registrant update confirm ready' do
      @domain.registrant_update_confirmable?('123').should == false
    end

    it 'should not find any domain pendings to clean' do
      Domain.clean_expired_pendings.should == 0
    end

    it 'should not find any domains with wrong pendings' do
      domain = Fabricate(:domain)
      domain.registrant_verification_asked!('frame-str', '1')
      domain.registrant_verification_asked_at = 30.days.ago
      domain.save

      Domain.clean_expired_pendings.should == 0
    end

    it 'should clean domain pendings' do
      domain = Fabricate(:domain)
      domain.registrant_verification_asked!('frame-str', '1')
      domain.registrant_verification_asked_at = 30.days.ago
      domain.pending_delete!

      DomainCron.clean_expired_pendings.should == 1
      domain.reload.pending_delete?.should == false
      domain.pending_json.should == {}
    end

    it 'should expire domains' do
      Setting.expire_warning_period = 1
      Setting.redemption_grace_period = 1

      DomainCron.start_expire_period
      @domain.statuses.include?(DomainStatus::EXPIRED).should == false

      old_valid_to = Time.zone.now - 10.days
      @domain.valid_to = old_valid_to
      @domain.save

      DomainCron.start_expire_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::EXPIRED).should == true

      DomainCron.start_expire_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::EXPIRED).should == true
    end

    it 'should start redemption grace period' do
      old_valid_to = Time.zone.now - 10.days
      @domain.valid_to = old_valid_to
      @domain.statuses = [DomainStatus::EXPIRED]
      @domain.outzone_at, @domain.delete_at = nil, nil
      @domain.save

      DomainCron.start_expire_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::EXPIRED).should == true
    end

    it 'should start redemption grace period' do
      domain = Fabricate(:domain)

      DomainCron.start_redemption_grace_period
      domain.reload
      domain.statuses.include?(DomainStatus::SERVER_HOLD).should == false
    end

    context 'with time period settings' do
      before :example do
        @save_days_to_renew = Setting.days_to_renew_domain_before_expire
        @save_warning_period = Setting.expire_warning_period
        @save_grace_period = Setting.redemption_grace_period
      end

      after :all do
        Setting.days_to_renew_domain_before_expire = @save_days_to_renew
        Setting.expire_warning_period = @save_warning_period
        Setting.redemption_grace_period = @save_grace_period
      end

      before :example do
        @domain.valid?
      end

      context 'with no renewal limit, renew anytime' do
        before do
          Setting.days_to_renew_domain_before_expire = 0
        end

        it 'should always renew with no policy' do
          @domain.renewable?.should be true
        end

        it 'should not allow to renew after force delete' do
          Setting.redemption_grace_period = 1
          @domain.schedule_force_delete
          @domain.renewable?.should be false
        end
      end

      context 'with renew policy' do
        before :example do
          @policy = 30
          Setting.days_to_renew_domain_before_expire = @policy
        end

        it 'should not allow renew before policy' do
          @domain.valid_to = Time.zone.now.beginning_of_day + @policy.days * 2
          @domain.renewable?.should be false
        end

        context 'ready to renew' do
          before { @domain.valid_to = Time.zone.now + (@policy - 2).days }

          it 'should allow renew' do
            @domain.renewable?.should be true
          end

          it 'should not allow to renew after force delete' do
            Setting.redemption_grace_period = 1
            @domain.schedule_force_delete
            @domain.renewable?.should be false
          end
        end
      end
    end

    it 'should set pending update' do
      @domain.statuses = DomainStatus::OK # restore
      @domain.save
      @domain.pending_update?.should == false

      @domain.set_pending_update
      @domain.pending_update?.should == true
      @domain.statuses = DomainStatus::OK # restore
    end

    it 'should not set pending update' do
      @domain.statuses = DomainStatus::OK # restore
      @domain.statuses << DomainStatus::CLIENT_UPDATE_PROHIBITED
      @domain.save

      @domain.set_pending_update.should == nil # not updated
      @domain.pending_update?.should == false
      @domain.statuses = DomainStatus::OK # restore
    end

    it 'should set pending delete' do
      @domain.statuses = DomainStatus::OK # restore
      @domain.save
      @domain.pending_delete?.should == false

      @domain.set_pending_delete
      @domain.save
      @domain.statuses.should == ['pendingDelete', 'serverHold']
      @domain.pending_delete?.should == true
      @domain.statuses = ['serverManualInzone']
      @domain.save
      @domain.set_pending_delete
      @domain.statuses.sort.should == ['pendingDelete', 'serverManualInzone'].sort
      @domain.statuses = DomainStatus::OK # restore
    end

    it 'should not set pending delele' do
      @domain.statuses = DomainStatus::OK # restore
      @domain.pending_delete?.should == false
      @domain.statuses << DomainStatus::CLIENT_DELETE_PROHIBITED
      @domain.save

      @domain.set_pending_delete.should == nil

      @domain.pending_delete?.should == false
      @domain.statuses = DomainStatus::OK # restore
    end

    it 'should add poll message to registrar' do
      domain = Fabricate(:domain, name: 'testpollmessage123.ee')
      domain.poll_message!(:poll_pending_update_confirmed_by_registrant)
      domain.registrar.messages.first.body.should == 'Registrant confirmed domain update: testpollmessage123.ee'
    end

    context 'about registrant update confirm' do
      before :example do
        @domain.registrant_verification_token = 123
        @domain.registrant_verification_asked_at = Time.zone.now
        @domain.statuses << DomainStatus::PENDING_UPDATE
      end

      it 'should be registrant update confirm ready' do
        @domain.registrant_update_confirmable?('123').should == true
      end

      it 'should not be registrant update confirm ready when token does not match' do
        @domain.registrant_update_confirmable?('wrong-token').should == false
      end

      it 'should not be registrant update confirm ready when no correct status' do
        @domain.statuses = []
        @domain.registrant_update_confirmable?('123').should == false
      end
    end

    context 'about registrant update confirm when domain is invalid' do
      before :example do
        @domain.registrant_verification_token = 123
        @domain.registrant_verification_asked_at = Time.zone.now
        @domain.statuses << DomainStatus::PENDING_UPDATE
      end

      it 'should be registrant update confirm ready' do
        @domain.registrant_update_confirmable?('123').should == true
      end

      it 'should not be registrant update confirm ready when token does not match' do
        @domain.registrant_update_confirmable?('wrong-token').should == false
      end

      it 'should not be registrant update confirm ready when no correct status' do
        @domain.statuses = []
        @domain.registrant_update_confirmable?('123').should == false
      end
    end

    context 'with versioning' do
      it 'should not have one version' do
        with_versioning do
          @domain.versions.size.should == 0
          @domain.name = 'new-test-name.ee'
          @domain.save
          @domain.errors.full_messages.should match_array([])
          @domain.versions.size.should == 1
        end
      end

      it 'should return api_creator when created by api user' do
        with_versioning do
          @user = Fabricate(:admin_user)
          @api_user = Fabricate(:api_user)
          @user.id.should == 1
          @api_user.id.should == 2
          ::PaperTrail.whodunnit = '2-ApiUser: testuser'

          @domain = Fabricate(:domain)
          @domain.creator_str.should == '2-ApiUser: testuser'

          @domain.creator.should == @api_user
          @domain.creator.should_not == @user
        end
      end

      it 'should return api_creator when created by api user' do
        with_versioning do
          @user = Fabricate(:admin_user, id: 1000)
          @api_user = Fabricate(:api_user, id: 2000)
          @user.id.should == 1000
          @api_user.id.should == 2000
          ::PaperTrail.whodunnit = '1000-AdminUser: testuser'

          @domain = Fabricate(:domain)
          @domain.creator_str.should == '1000-AdminUser: testuser'

          @domain.creator.should == @user
          @domain.creator.should_not == @api_user
        end
      end
    end
  end

  it 'validates domain name' do
    d = Fabricate(:domain)
    expect(d.name).to_not be_nil

    invalid = [
      'a.ee', "#{'a' * 64}.ee", 'ab.eu', 'test.ab.ee', '-test.ee', '-test-.ee',
      'test-.ee', 'te--st.ee', 'õ.pri.ee', 'www.ab.ee', 'test.eu', '  .ee', 'a b.ee',
      'Ž .ee', 'test.edu.ee'
    ]

    invalid.each do |x|
      expect(Fabricate.build(:domain, name: x).valid?).to be false
    end

    valid = [
      'ab.ee', "#{'a' * 63}.ee", 'te-s-t.ee', 'jäääär.ee', 'päike.pri.ee',
      'õigus.com.ee', 'õäöü.fie.ee', 'test.med.ee', 'žä.ee', '  ŽŠ.ee  '
    ]

    valid.each do |x|
      expect(Fabricate.build(:domain, name: x).valid?).to be true
    end

    invalid_punycode = ['xn--geaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-4we.pri.ee']

    invalid_punycode.each do |x|
      expect(Fabricate.build(:domain, name: x).valid?).to be false
    end

    valid_punycode = ['xn--ge-uia.pri.ee', 'xn--geaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-9te.pri.ee']

    valid_punycode.each do |x|
      expect(Fabricate.build(:domain, name: x).valid?).to be true
    end
  end

  it 'should not create zone origin domain' do
    d = Fabricate.build(:domain, name: 'ee')
    d.save.should == false
    expect(d.errors.full_messages).to include('Data management policy violation: Domain name is blocked [name]')

    d = Fabricate.build(:domain, name: 'bla')
    d.save.should == false
    expect(d.errors.full_messages).to include('Domain name Domain name is invalid')
  end

  it 'downcases domain' do
    d = Domain.new(name: 'TesT.Ee')
    expect(d.name).to eq('test.ee')
    expect(d.name_puny).to eq('test.ee')
    expect(d.name_dirty).to eq('test.ee')
  end

  it 'should be valid when name length is exatly 63 in characters' do
    d = Fabricate(:domain, name: "#{'a' * 63}.ee")
    d.valid?
    d.errors.full_messages.should == []
  end

  it 'should not be valid when name length is longer than 63 characters' do
    d = Fabricate.build(:domain, name: "#{'a' * 64}.ee")
    d.valid?
    d.errors.full_messages.should match_array([
      "Domain name Domain name is invalid",
      "Puny label Domain name is too long (maximum is 63 characters)"
    ])
  end

  it 'should not be valid when name length is longer than 63 characters' do
    d = Fabricate.build(:domain,
      name: "xn--4caaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.ee")
    d.valid?
    d.errors.full_messages.should match_array([
      "Domain name Domain name is invalid",
      "Puny label Domain name is too long (maximum is 63 characters)"
    ])
  end

  it 'should be valid when name length is 63 characters' do
    d = Fabricate.build(:domain,
                        name: "õäöüšžõäöüšžõäöüšžõäöüšžõäöüšžõäöüšžõäöüšžab123.pri.ee")
    d.valid?
    d.errors.full_messages.should match_array([
    ])
  end

  it 'should not be valid when name length is longer than 63 punycode characters' do
    d = Fabricate.build(:domain, name: "#{'ä' * 63}.ee")
    d.valid?
    d.errors.full_messages.should == [
      "Puny label Domain name is too long (maximum is 63 characters)"
    ]
  end

  it 'should not be valid when name length is longer than 63 punycode characters' do
    d = Fabricate.build(:domain, name: "#{'ä' * 64}.ee")
    d.valid?
    d.errors.full_messages.should match_array([
      "Domain name Domain name is invalid",
      "Puny label Domain name is too long (maximum is 63 characters)"
    ])
  end

  it 'should not be valid when name length is longer than 63 punycode characters' do
    d = Fabricate.build(:domain, name: "#{'ä' * 63}.pri.ee")
    d.valid?
    d.errors.full_messages.should match_array([
      "Puny label Domain name is too long (maximum is 63 characters)"
    ])
  end

  it 'should be valid when punycode name length is not longer than 63' do
    d = Fabricate.build(:domain, name: "#{'ä' * 53}.pri.ee")
    d.valid?
    d.errors.full_messages.should == []
  end

  it 'should be valid when punycode name length is not longer than 63' do
    d = Fabricate.build(:domain, name: "#{'ä' * 57}.ee")
    d.valid?
    d.errors.full_messages.should == []
  end

  it 'should not be valid when name length is one pynicode' do
    d = Fabricate.build(:domain, name: "xn--4ca.ee")
    d.valid?
    d.errors.full_messages.should == ["Domain name Domain name is invalid"]
  end

  it 'should not be valid with at character' do
    d = Fabricate.build(:domain, name: 'dass@sf.ee')
    d.valid?
    d.errors.full_messages.should == ["Domain name Domain name is invalid"]
  end

  it 'should not be valid with invalid characters' do
    d = Fabricate.build(:domain, name: '@ba)s(?ä_:-df.ee')
    d.valid?
    d.errors.full_messages.should == ["Domain name Domain name is invalid"]
  end

  it 'should be valid when name length is two pynicodes' do
    d = Fabricate.build(:domain, name: "xn--4caa.ee")
    d.valid?
    d.errors.full_messages.should == []
  end

  it 'should be valid when name length is two pynicodes' do
    d = Fabricate.build(:domain, name: "xn--4ca0b.ee")
    d.valid?
    d.errors.full_messages.should == []
  end

  it 'does not create a reserved domain' do
    Fabricate.create(:reserved_domain, name: 'test.ee')

    domain = Fabricate.build(:domain, name: 'test.ee')
    domain.validate

    expect(domain.errors[:base]).to include('Required parameter missing; reserved>pw element required for reserved domains')
  end

  it 'generates auth info' do
    d = Fabricate(:domain)
    expect(d.auth_info).to_not be_empty
  end

  it 'manages statuses automatically' do
    d = Fabricate(:domain)
    expect(d.statuses.count).to eq(1)
    expect(d.statuses.first).to eq(DomainStatus::OK)

    d.period = 2
    d.save

    d.reload
    expect(d.statuses.count).to eq(1)
    expect(d.statuses.first).to eq(DomainStatus::OK)

    d.statuses << DomainStatus::CLIENT_DELETE_PROHIBITED
    d.save

    d.reload

    expect(d.statuses.count).to eq(1)
    expect(d.statuses.first).to eq(DomainStatus::CLIENT_DELETE_PROHIBITED)
  end

  with_versioning do
    context 'when not saved' do
      it 'does not create domain version' do
        Fabricate.build(:domain)
        expect(DomainVersion.count).to eq(0)
      end

      it 'does not create child versions' do
        Fabricate.build(:domain)
        expect(ContactVersion.count).to eq(0)
        expect(NameserverVersion.count).to eq(0)
      end
    end

    context 'when saved' do
      before(:each) do
        Fabricate(:domain)
      end

      it 'creates domain version' do
        expect(DomainVersion.count).to eq(1)
        expect(ContactVersion.count).to eq(3)
        expect(NameserverVersion.count).to eq(3)
      end
    end
  end
end

RSpec.describe Domain, db: false do
  it { is_expected.to alias_attribute(:on_hold_time, :outzone_at) }
  it { is_expected.to alias_attribute(:outzone_time, :outzone_at) }

  describe 'nameserver validation', db: true do
    let(:domain) { described_class.new }

    it 'rejects less than min' do
      Setting.ns_min_count = 2
      domain.nameservers.build(FactoryGirl.attributes_for(:nameserver))
      domain.validate
      expect(domain.errors).to have_key(:nameservers)
    end

    it 'rejects more than max' do
      Setting.ns_min_count = 1
      Setting.ns_max_count = 1
      domain.nameservers.build(FactoryGirl.attributes_for(:nameserver))
      domain.nameservers.build(FactoryGirl.attributes_for(:nameserver))
      domain.validate
      expect(domain.errors).to have_key(:nameservers)
    end

    it 'accepts min' do
      Setting.ns_min_count = 1
      domain.nameservers.build(FactoryGirl.attributes_for(:nameserver))
      domain.validate
      expect(domain.errors).to_not have_key(:nameservers)
    end

    it 'accepts max' do
      Setting.ns_min_count = 1
      Setting.ns_max_count = 2
      domain.nameservers.build(FactoryGirl.attributes_for(:nameserver))
      domain.nameservers.build(FactoryGirl.attributes_for(:nameserver))
      domain.validate
      expect(domain.errors).to_not have_key(:nameservers)
    end

    context 'when nameserver is optional' do
      before :example do
        allow(Domain).to receive(:nameserver_required?).and_return(false)
      end

      it 'rejects less than min' do
        Setting.ns_min_count = 2
        domain.nameservers.build(FactoryGirl.attributes_for(:nameserver))
        domain.validate
        expect(domain.errors).to have_key(:nameservers)
      end

      it 'accepts absent' do
        domain.validate
        expect(domain.errors).to_not have_key(:nameservers)
      end
    end

    context 'when nameserver is required' do
      before :example do
        allow(Domain).to receive(:nameserver_required?).and_return(true)
      end

      it 'rejects absent' do
        domain.validate
        expect(domain.errors).to have_key(:nameservers)
      end
    end
  end

  describe '::nameserver_required?' do
    before do
      Setting.nameserver_required = 'test'
    end

    it 'returns setting value' do
      expect(described_class.nameserver_required?).to eq('test')
    end
  end

  describe '::expire_warning_period', db: true do
    before :example do
      Setting.expire_warning_period = 1
    end

    it 'returns expire warning period' do
      expect(described_class.expire_warning_period).to eq(1.day)
    end
  end

  describe '::redemption_grace_period', db: true do
    before :example do
      Setting.redemption_grace_period = 1
    end

    it 'returns redemption grace period' do
      expect(described_class.redemption_grace_period).to eq(1.day)
    end
  end

  describe '#set_server_hold' do
    let(:domain) { described_class.new }

    before :example do
      travel_to Time.zone.parse('05.07.2010')
      domain.set_server_hold
    end

    it 'sets corresponding status' do
      expect(domain.statuses).to include(DomainStatus::SERVER_HOLD)
    end

    it 'sets :outzone_at to now' do
      expect(domain.outzone_at).to eq(Time.zone.parse('05.07.2010'))
    end
  end

  describe '#admin_contact_names' do
    let(:domain) { described_class.new }

    before :example do
      expect(Contact).to receive(:names).and_return('names')
    end

    it 'returns admin contact names' do
      expect(domain.admin_contact_names).to eq('names')
    end
  end

  describe '#admin_contact_emails' do
    let(:domain) { described_class.new }

    before :example do
      expect(Contact).to receive(:emails).and_return('emails')
    end

    it 'returns admin contact emails' do
      expect(domain.admin_contact_emails).to eq('emails')
    end
  end

  describe '#tech_contact_names' do
    let(:domain) { described_class.new }

    before :example do
      expect(Contact).to receive(:names).and_return('names')
    end

    it 'returns technical contact names' do
      expect(domain.tech_contact_names).to eq('names')
    end
  end

  describe '#nameserver_hostnames' do
    let(:domain) { described_class.new }

    before :example do
      expect(Nameserver).to receive(:hostnames).and_return('hostnames')
    end

    it 'returns name server hostnames' do
      expect(domain.nameserver_hostnames).to eq('hostnames')
    end
  end

  describe '#primary_contact_emails' do
    let(:domain) { described_class.new }

    before :example do
      expect(domain).to receive(:registrant_email).and_return('registrant@test.com')
      expect(domain).to receive(:admin_contact_emails).and_return(%w(admin.contact@test.com admin.contact@test.com))
    end

    it 'returns unique list of registrant and administrative contact emails' do
      expect(domain.primary_contact_emails).to match_array(%w(
                                                   registrant@test.com
                                                   admin.contact@test.com
                                                 ))
    end
  end

  describe '#set_graceful_expired' do
    let(:domain) { described_class.new }

    before :example do
      expect(described_class).to receive(:expire_warning_period).and_return(1.day)
      expect(described_class).to receive(:redemption_grace_period).and_return(2.days)
      expect(domain).to receive(:valid_to).and_return(Time.zone.parse('05.07.2010 10:30'))

      domain.set_graceful_expired
    end

    it 'sets :outzone_at to :valid_to + expire warning period' do
      expect(domain.outzone_at).to eq(Time.zone.parse('06.07.2010 10:30'))
    end

    it 'sets :delete_at to :outzone_at + redemption grace period' do
      expect(domain.delete_at).to eq(Time.zone.parse('08.07.2010 10:30'))
    end
  end

  describe '::outzone_candidates', db: true do
    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')

      Fabricate(:zone, origin: 'ee')

      Fabricate.create(:domain, id: 1, outzone_time: Time.zone.parse('04.07.2010 23:59'))
      Fabricate.create(:domain, id: 2, outzone_time: Time.zone.parse('05.07.2010 00:00'))
      Fabricate.create(:domain, id: 3, outzone_time: Time.zone.parse('05.07.2010 00:01'))
    end

    it 'returns domains with outzone time in the past' do
      expect(described_class.outzone_candidates.ids).to eq([1])
    end
  end

  describe '::delete_candidates', db: true do
    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')

      Fabricate(:zone, origin: 'ee')

      Fabricate.create(:domain, id: 1, delete_time: Time.zone.parse('04.07.2010 23:59'))
      Fabricate.create(:domain, id: 2, delete_time: Time.zone.parse('05.07.2010 00:00'))
      Fabricate.create(:domain, id: 3, delete_time: Time.zone.parse('05.07.2010 00:01'))
    end

    it 'returns domains with delete time in the past' do
      expect(described_class.delete_candidates.ids).to eq([1])
    end
  end

  describe '::uses_zone?', db: true do
    let!(:zone) { create(:zone, origin: 'domain.tld') }

    context 'when zone is used' do
      let!(:domain) { create(:domain, name: 'test.domain.tld') }
      specify { expect(described_class.uses_zone?(zone)).to be true }
    end

    context 'when zone is unused' do
      specify { expect(described_class.uses_zone?(zone)).to be false }
    end
  end

  describe '#new_registrant_email' do
    let(:domain) { described_class.new(pending_json: { new_registrant_email: 'test@test.com' }) }

    it 'returns new registrant\'s email' do
      expect(domain.new_registrant_email).to eq('test@test.com')
    end
  end

  describe '#new_registrant_id' do
    let(:domain) { described_class.new(pending_json: { new_registrant_id: 1 }) }

    it 'returns new registrant\'s id' do
      expect(domain.new_registrant_id).to eq(1)
    end
  end
end
