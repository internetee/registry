require 'rails_helper'

describe DomainVersion do
  with_versioning do
    before(:each) { Fabricate(:domain_validation_setting_group); Fabricate(:dnskeys_setting_group) }
    before(:each) do
      Fabricate(:domain, name: 'version.ee') do
        owner_contact { Fabricate(:contact, name: 'owner_contact', code: 'asd', email: 'owner1@v.ee') }
        nameservers(count: 1) { Fabricate(:nameserver, hostname: 'ns.test.ee') }
        admin_contacts(count: 1) { Fabricate(:contact, name: 'admin_contact 1', code: 'qwe', email: 'admin1@v.ee') }
        tech_contacts(count: 1) { Fabricate(:contact, name: 'tech_contact 1', code: 'zxc', email: 'tech1@v.ee') }
      end
    end

    context 'when domain is created' do
      it('creates a domain version') { expect(DomainVersion.count).to eq(1) }
      it('has a snapshot') { expect(DomainVersion.first.snapshot).not_to be_empty }
      it 'has a snapshot with correct info' do
        expect(DomainVersion.last.load_snapshot).to eq({
          admin_contacts: [{ name: 'admin_contact 1', phone: '+372.12345678',
                             code: 'qwe', ident: '37605030299', email: 'admin1@v.ee' }],
          domain: { name: 'version.ee', status: nil },
          nameservers: [{ hostname: 'ns.test.ee', ipv4: nil, ipv6: nil }],
          owner_contact: { name: 'owner_contact', phone: '+372.12345678',
                           code: 'asd', ident: '37605030299', email: 'owner1@v.ee' },
          tech_contacts: [{ name: 'tech_contact 1', phone: '+372.12345678',
                            code: 'zxc', ident: '37605030299', email: 'tech1@v.ee' }]
        })
      end
    end

    context 'when domain is deleted' do
      it 'creates a version' do
        expect(DomainVersion.count).to eq(1)
        Domain.first.destroy
        expect(DomainVersion.count).to eq(2)
        expect(DomainVersion.last.load_snapshot).to eq({
          admin_contacts: [],
          domain: { name: 'version.ee', status: nil },
          nameservers: [],
          owner_contact: { name: 'owner_contact', phone: '+372.12345678',
                           code: 'asd', ident: '37605030299', email: 'owner1@v.ee' },
          tech_contacts: []
        })
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
        Domain.last.nameservers << Fabricate(:nameserver, hostname: 'ns.server.ee')
        expect(DomainVersion.count).to eq(2)
      end
    end

    context 'when removing child' do
      it('has one domain version before events'){ expect(DomainVersion.count).to eq(1) }
      before(:each) { Domain.last.nameservers << Fabricate(:nameserver) }

      it 'contact creates a version' do
        # FIXME For some reason nameservers disappeared mid-test, but randomly stopped happening
        expect(DomainVersion.count).to eq(1)
        DomainContact.last.destroy
        expect(Domain.last.valid?).to be(true)
        expect(DomainVersion.count).to eq(2)
      end

      it 'nameserver creates a version' do
        Domain.last.nameservers.last.destroy
        expect(DomainVersion.count).to eq(1)
        expect(Domain.last.nameservers.count).to eq(1)
        expect(DomainVersion.load_snapshot).to eq(
          admin_contacts: [{ name: 'admin_contact 1', phone: '+372.12345678',
                             code: 'qwe', ident: '37605030299', email: 'admin1@v.ee' }],
          domain: { name: 'version.ee', status: nil },
          nameservers: [{ hostname: 'ns.test.ee', ipv4: nil, ipv6: nil }],
          owner_contact: { name: 'owner_contact', phone: '+372.12345678',
                           code: 'asd', ident: '37605030299', email: 'owner1@v.ee' },
          tech_contacts: [{ name: 'tech_contact 1', phone: '+372.12345678',
                            code: 'zxc', ident: '37605030299', email: 'tech1@v.ee' }]
        )
      end
    end

    context 'when deleting children' do
      it 'creates a version' do
        expect(DomainVersion.count).to eq(1)
        Contact.find_by(name: 'tech_contact 1').destroy
        expect(DomainVersion.count).to eq(2)
        expect(DomainVersion.last.load_snapshot).to eq({
          admin_contacts: [{ name: 'admin_contact 1', phone: '+372.12345678',
                             code: 'qwe', ident: '37605030299', email: 'admin1@v.ee' }],
          domain: { name: 'version.ee', status: nil },
          nameservers: [{ hostname: 'ns.test.ee', ipv4: nil, ipv6: nil }],
          owner_contact: { name: 'owner_contact', phone: '+372.12345678',
                           code: 'asd', ident: '37605030299', email: 'owner1@v.ee' },
          tech_contacts: []
        })
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
        expect(DomainVersion.last.load_snapshot).to eq({
          admin_contacts: [{ name: 'edited admin_contact', phone: '+372.12345678',
                             code: 'qwe', ident: '37605030299', email: 'admin1@v.ee' }],
          domain: { name: 'version.ee', status: nil },
          nameservers: [{ hostname: 'ns.test.ee', ipv4: nil, ipv6: nil }],
          owner_contact: { name: 'edited owner_contact', phone: '+372.12345678',
                           code: 'asd', ident: '37605030299', email: 'owner1@v.ee' },
          tech_contacts: [{ name: 'edited tech_contact', phone: '+372.12345678',
                            code: 'zxc', ident: '37605030299', email: 'tech1@v.ee' }]
        })
      end
    end
  end
end
