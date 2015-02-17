require 'rails_helper'

describe Domain do
  before :all do
    create_settings
  end

  it { should belong_to(:registrar) }
  it { should have_many(:nameservers) }
  it { should belong_to(:owner_contact) }
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
        "Admin contacts Admin contacts count must be between 1-10",
        "Nameservers Nameservers count must be between 2-11",
        "Period Period is not a number",
        "Registrant Registrant is missing",
        "Registrar Registrar is missing"
      ])
    end

    it 'should not have any versions' do
      @domain.versions.should == []
    end

    it 'should not have whois_body' do
      @domain.whois_body.should == nil
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

    it 'should have whois_body' do
      @domain.whois_body.present?.should == true
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

      it 'should not find api creator when created by user' do
        with_versioning do
          # @api_user = Fabricate(:api_user)
          # @api_user.id.should == 1
          # ::PaperTrail.whodunnit = '1-testuser'

          # @domain = Fabricate(:domain)
          # @domain.creator_str.should == '1-testuser'

          # @domain.api_creator.should == nil
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
  # owner_contact: ['Registrant is missing'],
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
    expect(d.domain_statuses.count).to eq(1)
    expect(d.domain_statuses.first.value).to eq(DomainStatus::OK)

    d.period = 2
    d.save

    d.reload

    expect(d.domain_statuses.count).to eq(1)
    expect(d.domain_statuses.first.reload.value).to eq(DomainStatus::OK)

    d.domain_statuses.build(value: DomainStatus::CLIENT_DELETE_PROHIBITED)
    d.save

    d.reload

    expect(d.domain_statuses.count).to eq(1)
    expect(d.domain_statuses.first.value).to eq(DomainStatus::CLIENT_DELETE_PROHIBITED)
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
        expect(ContactVersion.count).to eq(2)
        expect(NameserverVersion.count).to eq(3)
      end
    end
  end
end
