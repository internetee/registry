require 'rails_helper'

describe Domain do
  it { should belong_to(:registrar) }
  it { should have_many(:nameservers) }
  it { should belong_to(:owner_contact) }
  it { should have_many(:tech_contacts) }
  it { should have_many(:admin_contacts) }
  it { should have_many(:domain_transfers) }
  it { should have_many(:dnskeys) }

  context 'with sufficient settings' do
    before(:each) do
      create_settings
    end

    it 'validates domain name' do
      d = Fabricate(:domain)
      expect(d.name).to_not be_nil

      invalid = ['a.ee', "#{'a' * 64}.ee", 'ab.eu', 'test.ab.ee', '-test.ee', '-test-.ee', 'test-.ee', 'te--st.ee',
                 'õ.pri.ee', 'test.com', 'www.ab.ee', 'test.eu', '  .ee', 'a b.ee', 'Ž .ee', 'test.edu.ee']

      invalid.each do |x|
        expect(Fabricate.build(:domain, name: x).valid?).to be false
      end

      valid = ['ab.ee', "#{'a' * 63}.ee", 'te-s-t.ee', 'jäääär.ee', 'päike.pri.ee',
               'õigus.com.ee', 'õäöü.fie.ee', 'test.med.ee', 'žä.ee', '  ŽŠ.ee  ']

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

      d = Domain.new
      expect(d.valid?).to be false
      expect(d.errors.messages).to match_array({
        period: ['is not a number'],
        owner_contact: ['Registrant is missing'],
        admin_contacts: ['Admin contacts count must be between 1 - infinity'],
        nameservers: ['Nameservers count must be between 2-11'],
        registrar: ['Registrar is missing'],
        period: ['Period is not a number']
      })

      Setting.ns_min_count = 2
      Setting.ns_max_count = 7

      expect(d.valid?).to be false
      expect(d.errors.messages[:nameservers]).to eq(['Nameservers count must be between 2-7'])
    end

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
