require 'rails_helper'

describe DomainVersion do
  with_versioning do
    before(:each) do
      Setting.ns_min_count = 1
      Fabricate(:domain, name: 'version.ee', dnskeys: [], domain_contacts: []) do
        owner_contact { Fabricate(:contact, name: 'owner_contact', code: 'asd', email: 'owner1@v.ee') }
        nameservers(count: 1) { Fabricate(:nameserver, hostname: 'ns.test.ee', ipv4: nil) }
        admin_contacts(count: 1) { Fabricate(:contact, name: 'admin_contact 1', code: 'qwe', email: 'admin1@v.ee') }
        tech_contacts(count: 1) { Fabricate(:contact, name: 'tech_contact 1', code: 'zxc', email: 'tech1@v.ee') }
      end
    end

    context 'when domain is created' do
      it('creates a domain version') { expect(DomainVersion.count).to eq(1) }
      it('has a snapshot') { expect(DomainVersion.first.snapshot).not_to be_empty }

      it('has a snapshot with admin_contacts') do
        expect(DomainVersion.last.load_snapshot[:admin_contacts].first).to include(
          name: 'admin_contact 1', phone: '+372.12345678', ident: '37605030299', email: 'admin1@v.ee'
        )
      end

      it('has a snapshot with domain') do
        expect(DomainVersion.last.load_snapshot[:domain]).to include(
          name: 'version.ee', status: nil
        )
      end

      it('has a snapshot with nameservers') do
        expect(DomainVersion.last.load_snapshot[:nameservers]).to include(
          hostname: 'ns.test.ee', ipv4: nil, ipv6: nil
        )
      end

      it('has a snapshot with owner contact') do
        expect(DomainVersion.last.load_snapshot[:owner_contact]).to include(
          name: 'owner_contact', phone: '+372.12345678', ident: '37605030299', email: 'owner1@v.ee'
        )
      end

      it('has a snapshot with tech contacts') do
        expect(DomainVersion.last.load_snapshot[:tech_contacts].first).to include(
          name: 'tech_contact 1', phone: '+372.12345678', ident: '37605030299', email: 'tech1@v.ee'
        )
      end
    end

    context 'when domain is deleted' do
      it 'creates a version' do
        expect(DomainVersion.count).to eq(1)
        Domain.first.destroy
        expect(DomainVersion.count).to eq(2)
        expect(DomainVersion.last.load_snapshot).to include({
          admin_contacts: [],
          #    domain: { name: 'version.ee', status: nil },
          nameservers: [],
          tech_contacts: []
        })
        expect(DomainVersion.last.load_snapshot[:owner_contact]).to include(
          { name: 'owner_contact', phone: '+372.12345678', ident: '37605030299', email: 'owner1@v.ee' }
        )
      end
    end

    context 'when adding child' do
      it 'contact creates a version' do
        expect(DomainVersion.count).to eq(1)
        expect(Domain.last.tech_contacts.count).to eq(1)
        Domain.last.tech_contacts << Fabricate(:contact, name: 'tech contact 2', phone: '+371.12345678',
                                                code: '123', email: 'tech2@v.ee')
        expect(Domain.last.tech_contacts.count).to eq(2)
        expect(DomainVersion.count).to eq(2)
      end

      it 'nameserver creates a version' do
        expect(DomainVersion.count).to eq(1)
        expect(Domain.last.nameservers.count).to eq(1)
        Domain.last.nameservers << Fabricate(:nameserver, hostname: 'ns.server.ee', created_at: Time.now - 20)
        expect(DomainVersion.count).to eq(2)
      end
    end

    context 'when removing child' do
      it('has one domain version before events') { expect(DomainVersion.count).to eq(1) }

      it 'contact creates a version' do
        expect(DomainVersion.count).to eq(1)
        DomainContact.last.destroy
        expect(Domain.last.valid?).to be(true)
        expect(DomainVersion.count).to eq(2)
      end

    end

    context 'when deleting child' do
      it 'contact creates a version' do
        expect(DomainVersion.count).to eq(1)
        Contact.find_by(name: 'tech_contact 1').destroy
        expect(DomainVersion.count).to eq(2)
        expect(DomainVersion.last.load_snapshot[:admin_contacts].size).to eq(1)
        expect(DomainVersion.last.load_snapshot[:admin_contacts].first).to include(
          name: 'admin_contact 1', phone: '+372.12345678', ident: '37605030299', email: 'admin1@v.ee'
        )

        expect(DomainVersion.last.load_snapshot[:domain][:name]).to eq('version.ee')
        expect(DomainVersion.last.load_snapshot[:domain][:status]).to eq(nil)
        expect(DomainVersion.last.load_snapshot[:domain][:period]).to eq(1)
        expect(DomainVersion.last.load_snapshot[:domain][:period_unit]).to eq('y')
        expect(DomainVersion.last.load_snapshot[:domain][:valid_from]).to eq(Time.now.utc.beginning_of_day)
        expect(DomainVersion.last.load_snapshot[:domain][:valid_to]).to eq(Time.now.utc.beginning_of_day + 1.year)
        expect(DomainVersion.last.load_snapshot[:domain][:period]).to eq(1)

        expect(DomainVersion.last.load_snapshot[:nameservers].size).to eq(1)
        expect(DomainVersion.last.load_snapshot[:nameservers].first).to include(
          hostname: 'ns.test.ee', ipv4: nil, ipv6: nil
        )
        expect(DomainVersion.last.load_snapshot[:owner_contact]).to include(
          { name: 'owner_contact', phone: '+372.12345678', ident: '37605030299', email: 'owner1@v.ee' }
        )
        expect(DomainVersion.last.load_snapshot[:tech_contacts]).to eq([])
      end

      it 'nameserver creates a version' do
        Domain.last.nameservers << Fabricate(:nameserver, created_at: Time.now - 30)
        Domain.last.nameservers.last.destroy
        expect(DomainVersion.count).to eq(3)
        expect(Domain.last.nameservers.count).to eq(1)

        expect(DomainVersion.last.load_snapshot[:admin_contacts].size).to eq(1)
        expect(DomainVersion.last.load_snapshot[:admin_contacts].first).to include(
          name: 'admin_contact 1', phone: '+372.12345678', ident: '37605030299', email: 'admin1@v.ee'
        )
        expect(DomainVersion.last.load_snapshot[:domain][:name]).to eq('version.ee')
        expect(DomainVersion.last.load_snapshot[:domain][:status]).to eq(nil)
        expect(DomainVersion.last.load_snapshot[:domain][:period]).to eq(1)
        expect(DomainVersion.last.load_snapshot[:domain][:period_unit]).to eq('y')

        expect(DomainVersion.last.load_snapshot[:nameservers].size).to eq(1)
        expect(DomainVersion.last.load_snapshot[:nameservers].first).to include(
          hostname: 'ns.test.ee', ipv4: nil, ipv6: nil
        )
        expect(DomainVersion.last.load_snapshot[:owner_contact]).to include(
          { name: 'owner_contact', phone: '+372.12345678', ident: '37605030299', email: 'owner1@v.ee' }
        )
        expect(DomainVersion.last.load_snapshot[:tech_contacts].size).to eq(1)
        expect(DomainVersion.last.load_snapshot[:tech_contacts].first).to include(
          name: 'tech_contact 1', phone: '+372.12345678', ident: '37605030299', email: 'tech1@v.ee'
        )
      end
    end

    context 'when editing children' do
      it 'creates a version' do
        expect(DomainVersion.count).to eq(1)
        Contact.find_by(name: 'owner_contact').update_attributes!(name: 'edited owner_contact')
        expect(DomainVersion.count).to eq(2)
      end

      it 'creates 3 versions' do
        expect(DomainVersion.count).to eq(1)
        Contact.find_by(name: 'owner_contact').update_attributes!(name: 'edited owner_contact')
        expect(DomainVersion.count).to eq(2)
        Contact.find_by(name: 'tech_contact 1').update_attributes!(name: 'edited tech_contact')
        expect(DomainVersion.count).to eq(3)
        Contact.find_by(name: 'admin_contact 1').update_attributes!(name: 'edited admin_contact')
        expect(DomainVersion.count).to eq(4)
        expect(DomainVersion.last.load_snapshot[:admin_contacts].size).to eq(1)
        expect(DomainVersion.last.load_snapshot[:admin_contacts].first).to include(
          name: 'edited admin_contact', phone: '+372.12345678', ident: '37605030299', email: 'admin1@v.ee'
        )
        expect(DomainVersion.last.load_snapshot[:domain][:name]).to eq('version.ee')
        expect(DomainVersion.last.load_snapshot[:domain][:status]).to eq(nil)
        expect(DomainVersion.last.load_snapshot[:domain][:period]).to eq(1)
        expect(DomainVersion.last.load_snapshot[:domain][:period_unit]).to eq('y')

        expect(DomainVersion.last.load_snapshot[:nameservers].size).to eq(1)
        expect(DomainVersion.last.load_snapshot[:nameservers].first).to include(
          hostname: 'ns.test.ee', ipv4: nil, ipv6: nil
        )
        expect(DomainVersion.last.load_snapshot[:owner_contact]).to include(
          { name: 'edited owner_contact', phone: '+372.12345678', ident: '37605030299', email: 'owner1@v.ee' }
        )
        expect(DomainVersion.last.load_snapshot[:tech_contacts].size).to eq(1)
        expect(DomainVersion.last.load_snapshot[:tech_contacts].first).to include(
          name: 'edited tech_contact', phone: '+372.12345678', ident: '37605030299', email: 'tech1@v.ee'
        )
      end
    end
  end
end
