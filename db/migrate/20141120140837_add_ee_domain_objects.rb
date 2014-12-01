class AddEeDomainObjects < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def up
    r = Registrar.create!(
      name: 'EIS',
      reg_no: '123321',
      address: 'Tallinn',
      country: Country.estonia
    )

    c = Contact.create!(
      name: 'EIS',
      phone: '+372.123321',
      email: 'info@testing.ee',
      ident: '123321',
      ident_type: 'ico',
      address: Address.create(
        city: 'Tallinn',
        country: Country.estonia
      ),
      registrar: r
    )

    EppUser.create!(
      registrar: r,
      username: 'testeis',
      password: 'testeis',
      active: true
    )

    Domain.create!(
      name: 'ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      owner_contact: c,
      nameservers: [
        Nameserver.create(hostname: 'ns.tld.ee', ipv4: '195.43.87.10'),
        Nameserver.create(hostname: 'b.tld.ee', ipv4: '194.146.106.110', ipv6: '2001:67c:1010:28::53'),
        Nameserver.create(hostname: 'e.tld.ee', ipv4: '204.61.216.36', ipv6: '2001:678:94:53::53'),
        Nameserver.create(hostname: 'ee.aso.ee', ipv4: '213.184.51.122', ipv6: '2a02:88:0:21::2'),
        Nameserver.create(hostname: 'ns.ut.ee', ipv4: '193.40.5.99', ipv6: ''),
        Nameserver.create(hostname: 'sunic.sunet.se', ipv4: '195.80.103.202')
      ],
      admin_contacts: [c],
      registrar: r
    )

    Domain.create!(
      name: 'pri.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      owner_contact: c,
      nameservers: [
        Nameserver.create(hostname: 'ns.tld.ee', ipv4: '195.43.87.10'),
        Nameserver.create(hostname: 'b.tld.ee', ipv4: '194.146.106.110', ipv6: '2001:67c:1010:28::53'),
        Nameserver.create(hostname: 'e.tld.ee', ipv4: '204.61.216.36', ipv6: '2001:678:94:53::53'),
        Nameserver.create(hostname: 'ee.aso.ee', ipv4: '213.184.51.122', ipv6: '2a02:88:0:21::2'),
        Nameserver.create(hostname: 'ns.ut.ee', ipv4: '193.40.5.99', ipv6: ''),
        Nameserver.create(hostname: 'sunic.sunet.se', ipv4: '195.80.103.202')
      ],
      admin_contacts: [c],
      registrar: r
    )
  end
  # rubocop:enable Metrics/MethodLength

  def down
    Domain.find_by(name: 'ee').destroy
    Domain.find_by(name: 'pri.ee').destroy
    EppUser.find_by(username: 'testeis').destroy
    Contact.find_by(name: 'EIS').destroy
    Registrar.find_by(name: 'EIS').destroy
  end
end
