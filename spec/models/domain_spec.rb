require 'rails_helper'

describe Domain do
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
  end

  context 'with valid attributes' do
    before :all do
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

    it 'should have correct validity dates' do
      valid_to = Time.zone.now + 1.year
      @domain.valid_to.should be_within(5).of(valid_to)
      @domain.outzone_at.should be_within(5).of(valid_to + Setting.expire_warning_period.days)
      @domain.delete_at.should be_within(5).of(
        valid_to + Setting.expire_warning_period.days + Setting.redemption_grace_period.days
      )
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

    it 'should expire domains' do
      Domain.start_expire_period
      @domain.statuses.include?(DomainStatus::EXPIRED).should == false

      @domain.valid_to = Time.zone.now - 10.days
      @domain.save

      Domain.start_expire_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::EXPIRED).should == true

      Domain.start_expire_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::EXPIRED).should == true
    end

    it 'should start redemption grace period' do
      Domain.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == false

      @domain.outzone_at = Time.zone.now
      @domain.statuses << DomainStatus::SERVER_MANUAL_INZONE # this prohibits server_hold
      @domain.save

      Domain.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == false

      @domain.statuses = []
      @domain.save

      Domain.start_redemption_grace_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::SERVER_HOLD).should == true
    end

    it 'should start delete period' do
      Domain.start_delete_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::DELETE_CANDIDATE).should == false

      @domain.delete_at = Time.zone.now
      @domain.statuses << DomainStatus::SERVER_DELETE_PROHIBITED # this prohibits delete_candidate
      @domain.save

      Domain.start_delete_period
      @domain.reload
      @domain.statuses.include?(DomainStatus::DELETE_CANDIDATE).should == false

      @domain.statuses = []
      @domain.save
      Domain.start_delete_period
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

      Domain.start_delete_period

      Domain.destroy_delete_candidates
      Domain.count.should == 0
    end

    it 'should set force delete time' do
      @domain.statuses = ['ok']
      @domain.set_force_delete

      @domain.statuses.count.should == 6
      fda = Time.zone.now + Setting.redemption_grace_period.days
      @domain.force_delete_at.should be_within(20).of(fda)

      @domain.unset_force_delete

      @domain.statuses.count.should == 1
      @domain.force_delete_at.should be_nil
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

    context 'about registrant update confirm' do
      before :all do
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
      before :all do
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
          ::PaperTrail.whodunnit = '2-api-testuser'

          @domain = Fabricate(:domain)
          @domain.creator_str.should == '2-api-testuser'

          @domain.creator.should == @api_user
          @domain.creator.should_not == @user
        end
      end

      it 'should return api_creator when created by api user' do
        with_versioning do
          @user = Fabricate(:admin_user)
          @api_user = Fabricate(:api_user)
          @user.id.should == 3
          @api_user.id.should == 4
          ::PaperTrail.whodunnit = '3-testuser'

          @domain = Fabricate(:domain)
          @domain.creator_str.should == '3-testuser'

          @domain.creator.should == @user
          @domain.creator.should_not == @api_user
        end
      end
    end
  end

  # it 'validates domain name', skip: true do
  # d = Fabricate(:domain)
  # expect(d.name).to_not be_nil

  # invalid = ['a.ee', "#{'a' * 64}.ee", 'ab.eu', 'test.ab.ee', '-test.ee', '-test-.ee', 'test-.ee', 'te--st.ee',
  # 'õ.pri.ee', 'test.com', 'www.ab.ee', 'test.eu', '  .ee', 'a b.ee', 'Ž .ee', 'test.edu.ee']

  # invalid.each do |x|
  # expect(Fabricate.build(:domain, name: x).valid?).to be false
  # end

  # valid = ['ab.ee', "#{'a' * 63}.ee", 'te-s-t.ee', 'jäääär.ee', 'päike.pri.ee',
  # 'õigus.com.ee', 'õäöü.fie.ee', 'test.med.ee', 'žä.ee', '  ŽŠ.ee  ']

  # valid.each do |x|
  # expect(Fabricate.build(:domain, name: x).valid?).to be true
  # end

  # invalid_punycode = ['xn--geaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-4we.pri.ee']

  # invalid_punycode.each do |x|
  # expect(Fabricate.build(:domain, name: x).valid?).to be false
  # end

  # valid_punycode = ['xn--ge-uia.pri.ee', 'xn--geaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-9te.pri.ee']

  # valid_punycode.each do |x|
  # expect(Fabricate.build(:domain, name: x).valid?).to be true
  # end

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
