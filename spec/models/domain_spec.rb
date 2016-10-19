require 'rails_helper'

describe Domain do
  before :all do
    Fabricate(:zonefile_setting, origin: 'ee')
    Fabricate(:zonefile_setting, origin: 'pri.ee')
    Fabricate(:zonefile_setting, origin: 'med.ee')
    Fabricate(:zonefile_setting, origin: 'fie.ee')
    Fabricate(:zonefile_setting, origin: 'com.ee')
  end

  it { should belong_to(:registrar) }
  it { should have_many(:nameservers) }
  it { should belong_to(:registrant) }
  it { should have_many(:tech_contacts) }
  it { should have_many(:admin_contacts) }
  it { should have_many(:domain_transfers) }
  it { should have_many(:dnskeys) }
  it { should have_many(:legal_documents) }

  context 'with invalid attribute' do
    before :all do
      @domain = Domain.new
    end

    it 'should not be valid' do
      @domain.valid?
      @domain.errors.full_messages.should match_array([
        "Admin domain contacts Admin contacts count must be between 1-10",
        "Nameservers Nameservers count must be between 2-11",
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

    after do
      @domain.delete
      @domain = nil
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

    it 'should have correct validity dates' do
      valid_to = Time.zone.now + 1.year
      @domain.valid_to.should be_within(5).of(valid_to)
      @domain.outzone_at.should be_nil
      @domain.delete_at.should be_nil
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
      DomainCron.start_expire_period
      @domain.statuses.include?(DomainStatus::EXPIRED).should == false

      old_valid_to = Time.zone.now - 10.days
      @domain.valid_to = old_valid_to
      @domain.save

      DomainCron.start_expire_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::EXPIRED).should == true
      @domain.outzone_at.should be_within(5).of(old_valid_to + Setting.expire_warning_period.days)
      @domain.delete_at.should be_within(5).of(
        old_valid_to + Setting.expire_warning_period.days + Setting.redemption_grace_period.days
      )

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
      @domain.outzone_at.should be_within(5).of(old_valid_to + Setting.expire_warning_period.days)
      @domain.delete_at.should be_within(5).of(
        old_valid_to + Setting.expire_warning_period.days + Setting.redemption_grace_period.days
      )
    end

    it 'should start redemption grace period' do
      DomainCron.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == false

      @domain.outzone_at = Time.zone.now
      @domain.statuses << DomainStatus::SERVER_MANUAL_INZONE # this prohibits server_hold
      @domain.save

      DomainCron.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == false

      @domain.statuses = []
      @domain.save

      DomainCron.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == true
    end

    it 'should start delete period' do
      DomainCron.start_delete_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::DELETE_CANDIDATE).should == false

      @domain.delete_at = Time.zone.now
      @domain.statuses << DomainStatus::SERVER_DELETE_PROHIBITED # this prohibits delete_candidate
      @domain.save

      DomainCron.start_delete_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::DELETE_CANDIDATE).should == false

      @domain.statuses = []
      @domain.save
      DomainCron.start_delete_period
      @domain.reload

      @domain.statuses.include?(DomainStatus::DELETE_CANDIDATE).should == true
    end

    it 'should destroy delete candidates' do
      d = Fabricate(:domain)
      d.force_delete_at = Time.zone.now
      d.save

      @domain.delete_at = Time.zone.now
      @domain.save

      Domain.count.should == 2

      DomainCron.start_delete_period

      Domain.destroy_delete_candidates
      Domain.count.should == 0
    end

    it 'should set force delete time' do
      @domain.statuses = ['ok']
      @domain.set_force_delete

      @domain.statuses.should match_array([
        "serverForceDelete",
        "pendingDelete",
        "serverManualInzone",
        "serverRenewProhibited",
        "serverTransferProhibited",
        "serverUpdateProhibited"
      ])

      fda = Time.zone.now + Setting.redemption_grace_period.days
      @domain.force_delete_at.should be_within(20).of(fda)

      @domain.registrar.messages.count.should == 1
      m = @domain.registrar.messages.first
      m.body.should == "Force delete set on domain #{@domain.name}"

      @domain.unset_force_delete

      @domain.statuses.should == ['ok']
      @domain.force_delete_at.should be_nil

      @domain.statuses = [
        DomainStatus::CLIENT_DELETE_PROHIBITED,
        DomainStatus::SERVER_DELETE_PROHIBITED,
        DomainStatus::PENDING_UPDATE,
        DomainStatus::PENDING_TRANSFER,
        DomainStatus::PENDING_RENEW,
        DomainStatus::PENDING_CREATE,
        DomainStatus::CLIENT_HOLD,
        DomainStatus::EXPIRED,
        DomainStatus::SERVER_HOLD,
        DomainStatus::DELETE_CANDIDATE
      ]

      @domain.save

      @domain.set_force_delete

      @domain.statuses.should match_array([
        "clientHold",
        "deleteCandidate",
        "expired",
        "serverForceDelete",
        "pendingDelete",
        "serverHold",
        "serverRenewProhibited",
        "serverTransferProhibited",
        "serverUpdateProhibited"
      ])

      @domain.unset_force_delete

      @domain.statuses.should match_array([
        "clientDeleteProhibited",
        "clientHold",
        "deleteCandidate",
        "expired",
        "pendingCreate",
        "pendingRenew",
        "pendingTransfer",
        "pendingUpdate",
        "serverDeleteProhibited",
        "serverHold"
      ])
    end

    it 'should should be manual in zone and held after force delete' do
      @domain.valid?
      @domain.outzone_at = Time.zone.now + 1.day # before redemption grace period
      # what should this be?
      # @domain.server_holdable?.should be true
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should be false
      @domain.statuses.include?(DomainStatus::SERVER_MANUAL_INZONE).should be false
      @domain.set_force_delete
      @domain.server_holdable?.should be false
      @domain.statuses.include?(DomainStatus::SERVER_MANUAL_INZONE).should be true
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should be false
    end

    it 'should not allow update after force delete' do
      @domain.valid?
      @domain.pending_update_prohibited?.should be false
      @domain.update_prohibited?.should be false
      @domain.set_force_delete
      @domain.pending_update_prohibited?.should be true
      @domain.update_prohibited?.should be true
    end

    context 'with time period settings' do
      before :all do
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
          @domain.set_force_delete
          @domain.renewable?.should be false
        end
      end

      context 'with renew policy' do
        before :all do
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
            @domain.set_force_delete
            @domain.renewable?.should be false
          end
        end
      end
    end

    it 'should start redemption grace period' do
      DomainCron.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == false

      @domain.outzone_at = Time.zone.now
      @domain.statuses << DomainStatus::SERVER_MANUAL_INZONE # this prohibits server_hold
      @domain.save

      DomainCron.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == false

      @domain.statuses = []
      @domain.save

      DomainCron.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == true
    end


    it 'should set expired status and update outzone_at and delete_at' do
      domain = Fabricate(:domain)
      domain.statuses.should == ['ok']
      domain.set_expired
      domain.changes.keys.should == ['statuses', 'outzone_at', 'delete_at']
      domain.save

      domain.statuses.should == ['expired']
    end

    it 'should know its create price' do
      Fabricate(:pricelist, {
        category: 'ee',
        operation_category: 'create',
        duration: '1year',
        price: 1.50,
        valid_from: Time.zone.parse('2015-01-01'),
        valid_to: nil
      })

      domain = Fabricate(:domain)
      domain.pricelist('create').price.amount.should == 1.50

      domain = Fabricate(:domain, period: 12, period_unit: 'm')
      domain.pricelist('create').price.amount.should == 1.50

      domain = Fabricate(:domain, period: 365, period_unit: 'd')
      domain.pricelist('create').price.amount.should == 1.50

      Fabricate(:pricelist, {
        category: 'ee',
        operation_category: 'create',
        duration: '2years',
        price: 3,
        valid_from: Time.zone.parse('2015-01-01'),
        valid_to: nil
      })

      domain = Fabricate(:domain, period: 2)
      domain.pricelist('create').price.amount.should == 3.0

      domain = Fabricate(:domain, period: 24, period_unit: 'm')
      domain.pricelist('create').price.amount.should == 3.0

      domain = Fabricate(:domain, period: 730, period_unit: 'd')
      domain.pricelist('create').price.amount.should == 3.0

      Fabricate(:pricelist, {
        category: 'ee',
        operation_category: 'create',
        duration: '3years',
        price: 6,
        valid_from: Time.zone.parse('2015-01-01'),
        valid_to: nil
      })

      domain = Fabricate(:domain, period: 3)
      domain.pricelist('create').price.amount.should == 6.0

      domain = Fabricate(:domain, period: 36, period_unit: 'm')
      domain.pricelist('create').price.amount.should == 6.0

      domain = Fabricate(:domain, period: 1095, period_unit: 'd')
      domain.pricelist('create').price.amount.should == 6.0
    end

    it 'should know its renew price' do
      Fabricate(:pricelist, {
        category: 'ee',
        operation_category: 'renew',
        duration: '1year',
        price: 1.30,
        valid_from: Time.zone.parse('2015-01-01'),
        valid_to: nil
      })

      domain = Fabricate(:domain)
      domain.pricelist('renew').price.amount.should == 1.30

      domain = Fabricate(:domain, period: 12, period_unit: 'm')
      domain.pricelist('renew').price.amount.should == 1.30

      domain = Fabricate(:domain, period: 365, period_unit: 'd')
      domain.pricelist('renew').price.amount.should == 1.30

      Fabricate(:pricelist, {
        category: 'ee',
        operation_category: 'renew',
        duration: '2years',
        price: 3.1,
        valid_from: Time.zone.parse('2015-01-01'),
        valid_to: nil
      })

      domain = Fabricate(:domain, period: 2)
      domain.pricelist('renew').price.amount.should == 3.1

      domain = Fabricate(:domain, period: 24, period_unit: 'm')
      domain.pricelist('renew').price.amount.should == 3.1

      domain = Fabricate(:domain, period: 730, period_unit: 'd')
      domain.pricelist('renew').price.amount.should == 3.1

      Fabricate(:pricelist, {
        category: 'ee',
        operation_category: 'renew',
        duration: '3years',
        price: 6.1,
        valid_from: Time.zone.parse('2015-01-01'),
        valid_to: nil
      })

      domain = Fabricate(:domain, period: 3)
      domain.pricelist('renew').price.amount.should == 6.1

      domain = Fabricate(:domain, period: 36, period_unit: 'm')
      domain.pricelist('renew').price.amount.should == 6.1

      domain = Fabricate(:domain, period: 1095, period_unit: 'd')
      domain.pricelist('renew').price.amount.should == 6.1
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
      'test-.ee', 'te--st.ee', 'õ.pri.ee', 'test.com', 'www.ab.ee', 'test.eu', '  .ee', 'a b.ee',
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
    d.errors.full_messages.should match_array([
      "Data management policy violation: Domain name is blocked [name]"
    ])

    d = Fabricate.build(:domain, name: 'bla')
    d.save.should == false
    d.errors.full_messages.should match_array([
      "Domain name Domain name is invalid"
    ])
  end

  # d = Domain.new
  # expect(d.valid?).to be false
  # expect(d.errors.messages).to match_array({
  # registrant: ['Registrant is missing'],
  # admin_contacts: ['Admin contacts count must be between 1 - infinity'],
  # nameservers: ['Nameservers count must be between 2-11'],
  # registrar: ['Registrar is missing'],
  # period: ['Period is not a number']
  # })

  # Setting.ns_min_count = 2
  # Setting.ns_max_count = 7

  # expect(d.valid?).to be false
  # expect(d.errors.messages[:nameservers]).to eq(['Nameservers count must be between 2-7'])
  # end

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

  it 'normalizes ns attrs' do
    d = Fabricate(:domain)
    d.nameservers.build(hostname: 'BLA.EXAMPLE.EE', ipv4: '   192.168.1.1', ipv6: '1080:0:0:0:8:800:200c:417a')
    d.save

    ns = d.nameservers.last
    expect(ns.hostname).to eq('bla.example.ee')
    expect(ns.ipv4).to eq('192.168.1.1')
    expect(ns.ipv6).to eq('1080:0:0:0:8:800:200C:417A')
  end

  it 'does not create a reserved domain' do
    Fabricate(:reserved_domain)
    expect(Fabricate.build(:domain, name: '1162.ee').valid?).to be false
  end

  it 'validates period' do
    expect(Fabricate.build(:domain, period: 0).valid?).to be false
    expect(Fabricate.build(:domain, period: 4).valid?).to be false
    expect(Fabricate.build(:domain, period: 3).valid?).to be true
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
        # Fabricate(:domain_validation_setting_group)
        # Fabricate(:dnskeys_setting_group)
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
end
