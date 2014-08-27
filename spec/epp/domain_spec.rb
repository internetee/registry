require 'rails_helper'

describe 'EPP Domain', epp: true do
  let(:server) { server = Epp::Server.new({ server: 'localhost', tag: 'gitlab', password: 'ghyt9e4fu', port: 701 }) }

  context 'with valid user' do
    before(:each) do
      Fabricate(:epp_user)
      Fabricate(:domain_validation_setting_group)
      Fabricate(:domain_statuses_setting_group)
    end

    it 'returns error if contact does not exists' do
      Fabricate(:contact, code: 'jd1234')

      response = epp_request(domain_create_xml, :xml)
      expect(response[:results][0][:result_code]).to eq('2303')
      expect(response[:results][0][:msg]).to eq('Contact was not found')
      expect(response[:results][0][:value]).to eq('sh8013')

      expect(response[:results][1][:result_code]).to eq('2303')
      expect(response[:results][1][:msg]).to eq('Contact was not found')
      expect(response[:results][1][:value]).to eq('sh801333')

      expect(response[:results][2][:result_code]).to eq('2303')
      expect(response[:results][2][:msg]).to eq('Contact was not found')
      expect(response[:results][2][:value]).to eq('sh8013')

      expect(response[:clTRID]).to eq('ABC-12345')
    end

    context 'with citizen as an owner' do
      before(:each) do
        Fabricate(:contact, code: 'jd1234')
        Fabricate(:contact, code: 'sh8013')
        Fabricate(:contact, code: 'sh801333')
      end

      it 'creates a domain' do
        response = epp_request(domain_create_xml, :xml)

        d = Domain.first

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')

        cre_data = response[:parsed].css('creData')

        expect(cre_data.css('name').text).to eq('example.ee')
        expect(cre_data.css('crDate').text).to eq(d.created_at.to_time.utc.to_s)
        expect(cre_data.css('exDate').text).to eq(d.valid_to.to_time.utc.to_s)

        expect(response[:clTRID]).to eq('ABC-12345')

        expect(d.registrar.name).to eq('Zone Media OÜ')
        expect(d.tech_contacts.count).to eq 2
        expect(d.admin_contacts.count).to eq 1

        expect(d.nameservers.count).to eq(2)
      end

      it 'does not create duplicate domain' do
        epp_request(domain_create_xml, :xml)
        response = epp_request(domain_create_xml, :xml)
        expect(response[:result_code]).to eq('2302')
        expect(response[:msg]).to eq('Domain name already exists')
        expect(response[:clTRID]).to eq('ABC-12345')
      end

      it 'does not create reserved domain' do
        Fabricate(:reserved_domain)

        xml = domain_create_xml(name: '1162.ee')

        response = epp_request(xml, :xml)
        expect(response[:result_code]).to eq('2302')
        expect(response[:msg]).to eq('Domain name is reserved or restricted')
        expect(response[:clTRID]).to eq('ABC-12345')
      end

      it 'does not create domain without contacts and registrant' do
        xml = domain_create_xml(contacts: [], registrant: false)

        response = epp_request(xml, :xml)
        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: contact')

        expect(response[:results][1][:result_code]).to eq('2003')
        expect(response[:results][1][:msg]).to eq('Required parameter missing: registrant')
      end

      it 'does not create domain without nameservers' do
        xml = domain_create_xml(nameservers: [])
        response = epp_request(xml, :xml)
        expect(response[:result_code]).to eq('2003')
        expect(response[:msg]).to eq('Required parameter missing: ns')
      end

      it 'does not create domain with too many nameservers' do
        nameservers = []
        14.times { |i| nameservers << { hostObj: "ns#{i}.example.net" } }
        xml = domain_create_xml(nameservers: nameservers)

        response = epp_request(xml, :xml)
        expect(response[:result_code]).to eq('2004')
        expect(response[:msg]).to eq('Nameservers count must be between 1-13')
      end

      it 'returns error when invalid nameservers are present' do
        xml = domain_create_xml(nameservers: [{ hostObj: 'invalid1-' }, { hostObj: '-invalid2' }])

        response = epp_request(xml, :xml)
        expect(response[:result_code]).to eq('2005')
        expect(response[:msg]).to eq('Hostname is invalid')
      end

      it 'creates domain with nameservers with ips' do
        response = epp_request('domains/create_w_host_attrs.xml')
        expect(Domain.first.nameservers.count).to eq(2)
        ns = Domain.first.nameservers.first
        expect(ns.ipv4).to eq('192.0.2.2')
        expect(ns.ipv6).to eq('1080:0:0:0:8:800:200C:417A')
      end

      it 'returns error when nameserver has invalid ips' do
        response = epp_request('domains/create_w_invalid_ns_ip.xml')
        expect(response[:results][0][:result_code]).to eq '2005'
        expect(response[:results][0][:msg]).to eq 'IPv4 is invalid'
        expect(response[:results][0][:value]).to eq '192.0.2.2.invalid'
        expect(response[:results][1][:result_code]).to eq '2005'
        expect(response[:results][1][:msg]).to eq 'IPv6 is invalid'
        expect(response[:results][1][:value]).to eq 'invalid_ipv6'
        expect(Domain.count).to eq(0)
        expect(Nameserver.count).to eq(0)
      end

      it 'creates a domain with period in days' do
        xml = domain_create_xml(period_value: 365, period_unit: 'd')

        response = epp_request(xml, :xml)
        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(Domain.first.valid_to).to eq(Date.today + 1.year)
      end

      it 'does not create a domain with invalid period' do
        xml = domain_create_xml(period_value: 367, period_unit: 'd')

        response = epp_request(xml, :xml)
        expect(response[:results][0][:result_code]).to eq('2004')
        expect(response[:results][0][:msg]).to eq('Period must add up to 1, 2 or 3 years')
        expect(response[:results][0][:value]).to eq('367')
      end
    end

    context 'with juridical persion as an owner' do
      before(:each) do
        Fabricate(:contact, code: 'jd1234', ident_type: 'ico')
        Fabricate(:contact, code: 'sh8013')
        Fabricate(:contact, code: 'sh801333')
      end

      it 'creates a domain with contacts' do
        xml = domain_create_xml(contacts: [{ contact_value: 'sh8013', contact_type: 'admin' }])

        response = epp_request(xml, :xml)
        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(response[:clTRID]).to eq('ABC-12345')

        expect(Domain.first.tech_contacts.count).to eq 1
        expect(Domain.first.admin_contacts.count).to eq 1

        tech_contact = Domain.first.tech_contacts.first
        expect(tech_contact.code).to eq('jd1234')
      end

      it 'does not create a domain without admin contact' do
        xml = domain_create_xml(contacts: [{ contact_value: 'sh8013', contact_type: 'tech' }])

        response = epp_request(xml, :xml)
        expect(response[:result_code]).to eq('2306')
        expect(response[:msg]).to eq('Admin contacts count must be between 1 - infinity')
        expect(response[:clTRID]).to eq('ABC-12345')

        expect(Domain.count).to eq 0
        expect(DomainContact.count).to eq 0
      end
    end

    context 'with valid domain' do
      before(:each) { Fabricate(:domain, name: 'example.ee') }

      it 'renews a domain' do
        response = epp_request(domain_renew_xml, :xml)
        exDate = response[:parsed].css('renData exDate').text
        name = response[:parsed].css('renData name').text
        expect(exDate).to eq ('2015-08-07 00:00:00 UTC')
        expect(name).to eq ('example.ee')
      end

      it 'returns an error when given and current exp dates do not match' do
        xml = domain_renew_xml(curExpDate: '2016-08-07')

        response = epp_request(xml, :xml)
        expect(response[:results][0][:result_code]).to eq('2306')
        expect(response[:results][0][:msg]).to eq('Given and current expire dates do not match')
      end

      it 'returns an error when period is invalid' do
        xml = domain_renew_xml(period_value: 4)

        response = epp_request(xml, :xml)
        expect(response[:results][0][:result_code]).to eq('2004')
        expect(response[:results][0][:msg]).to eq('Period must add up to 1, 2 or 3 years')
        expect(response[:results][0][:value]).to eq('4')
      end

      it 'returns domain info' do
        d = Domain.first
        d.domain_statuses.create(setting: Setting.find_by(code: 'client_hold'), description: 'Payment overdue.')
        d.nameservers.create(hostname: 'ns1.example.com', ipv4: '192.168.1.1', ipv6: '1080:0:0:0:8:800:200C:417A')

        response = epp_request(domain_info_xml, :xml)
        expect(response[:results][0][:result_code]).to eq('1000')
        expect(response[:results][0][:msg]).to eq('Command completed successfully')

        inf_data = response[:parsed].css('resData infData')
        expect(inf_data.css('name').text).to eq('example.ee')
        expect(inf_data.css('status').text).to eq('Payment overdue.')
        expect(inf_data.css('status').first[:s]).to eq('clientHold')
        expect(inf_data.css('registrant').text).to eq(d.owner_contact_code)

        admin_contacts_from_request = inf_data.css('contact[type="admin"]').map { |x| x.text }
        admin_contacts_existing = d.admin_contacts.pluck(:code)

        expect(admin_contacts_from_request).to eq(admin_contacts_existing)

        hosts_from_request = inf_data.css('hostObj').map { |x| x.text }
        hosts_existing = d.nameservers.where(ipv4: nil).pluck(:hostname)

        expect(hosts_from_request).to eq(hosts_existing)

        expect(inf_data.css('hostName').first.text).to eq('ns1.example.com')
        expect(inf_data.css('hostAddr').first.text).to eq('192.168.1.1')
        expect(inf_data.css('hostAddr').last.text).to eq('1080:0:0:0:8:800:200C:417A')
        expect(inf_data.css('crDate').text).to eq(d.created_at.to_time.utc.to_s)
        expect(inf_data.css('exDate').text).to eq(d.valid_to.to_time.utc.to_s)

        expect(inf_data.css('pw').text).to eq(d.auth_info)

        d.touch

        response = epp_request(domain_info_xml, :xml)
        inf_data = response[:parsed].css('resData infData')

        expect(inf_data.css('upDate').text).to eq(d.updated_at.to_time.utc.to_s)
      end

      it 'returns error when domain can not be found' do
        response = epp_request(domain_info_xml(name_value: 'test.ee'), :xml)
        expect(response[:results][0][:result_code]).to eq('2303')
        expect(response[:results][0][:msg]).to eq('Domain not found')
      end

      it 'updates domain and adds objects' do
        response = epp_request('domains/update_add_objects.xml')
        expect(response[:results][0][:result_code]).to eq('2303')
        expect(response[:results][0][:msg]).to eq('Contact was not found')

        Fabricate(:contact, code: 'mak21')

        response = epp_request('domains/update_add_objects.xml')
        expect(response[:results][0][:result_code]).to eq('1000')

        d = Domain.first

        new_ns_count = d.nameservers.where(hostname: ['ns1.example.com', 'ns2.example.com']).count
        expect(new_ns_count).to eq(2)

        new_contact = d.tech_contacts.find_by(code: 'mak21')
        expect(new_contact).to be_truthy

        expect(d.domain_statuses.count).to eq(2)
        expect(d.domain_statuses.first.description).to eq('Payment overdue.')
        expect(d.domain_statuses.first.value).to eq('clientHold')
        expect(d.domain_statuses.first.code).to eq('client_hold')

        expect(d.domain_statuses.last.value).to eq('clientUpdateProhibited')

        response = epp_request('domains/update_add_objects.xml')
        expect(response[:results][0][:result_code]).to eq('2302')
        expect(response[:results][0][:msg]).to eq('Nameserver already exists on this domain')
        expect(response[:results][0][:value]).to eq('ns1.example.com')
        expect(response[:results][1][:msg]).to eq('Nameserver already exists on this domain')
        expect(d.domain_statuses.count).to eq(2)
      end

      it 'updates a domain and removes objects' do
        Fabricate(:contact, code: 'mak21')
        epp_request('domains/update_add_objects.xml')

        d = Domain.last

        epp_request('domains/update_remove_objects.xml')

        expect(d.domain_statuses.count).to eq(1)
        expect(d.domain_statuses.first.value).to eq('clientUpdateProhibited')

        rem_ns = d.nameservers.find_by(hostname: 'ns1.example.com')
        expect(rem_ns).to be_falsey

        rem_cnt = d.tech_contacts.find_by(code: 'mak21')
        expect(rem_cnt).to be_falsey

        response = epp_request('domains/update_remove_objects.xml')
        expect(response[:results][0][:result_code]).to eq('2303')
        expect(response[:results][0][:msg]).to eq('Contact was not found')
        expect(response[:results][0][:value]).to eq('mak21')

        expect(response[:results][1][:result_code]).to eq('2303')
        expect(response[:results][1][:msg]).to eq('Nameserver was not found')
        expect(response[:results][1][:value]).to eq('ns1.example.com')

        expect(response[:results][2][:result_code]).to eq('2303')
        expect(response[:results][2][:msg]).to eq('Status was not found')
        expect(response[:results][2][:value]).to eq('clientHold')
      end

      it 'does not add duplicate objects to domain' do
        Fabricate(:contact, code: 'mak21')
        epp_request('domains/update_add_objects.xml')
        response = epp_request('domains/update_add_objects.xml')

        expect(response[:results][0][:result_code]).to eq('2302')
        expect(response[:results][0][:msg]).to eq('Nameserver already exists on this domain')
        expect(response[:results][0][:value]).to eq('ns1.example.com')
      end

      it 'updates a domain' do
        Fabricate(:contact, code: 'mak21')
        epp_request('domains/update_add_objects.xml')
        response = epp_request(domain_update_xml, :xml)

        expect(response[:results][0][:result_code]).to eq('1000')

        d = Domain.last

        expect(d.owner_contact_code).to eq('mak21')
        expect(d.auth_info).to eq('2BARfoo')
      end
    end

    it 'checks a domain' do
      response = epp_request(domain_check_xml, :xml)
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      domain = response[:parsed].css('resData chkData cd name').first
      expect(domain.text).to eq('example.ee')
      expect(domain[:avail]).to eq('1')

      Fabricate(:domain, name: 'example.ee')

      response = epp_request(domain_check_xml, :xml)
      domain = response[:parsed].css('resData chkData cd').first
      name = domain.css('name').first
      reason = domain.css('reason').first

      expect(name.text).to eq('example.ee')
      expect(name[:avail]).to eq('0')
      expect(reason.text).to eq('in use')
    end

    it 'checks multiple domains' do
      xml = domain_check_xml(names: ['one.ee', 'two.ee', 'three.ee'])

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      domain = response[:parsed].css('resData chkData cd name').first
      expect(domain.text).to eq('one.ee')
      expect(domain[:avail]).to eq('1')

      domain = response[:parsed].css('resData chkData cd name').last
      expect(domain.text).to eq('three.ee')
      expect(domain[:avail]).to eq('1')
    end

    it 'checks invalid format domain' do
      xml = domain_check_xml(names: ['one.ee', 'notcorrectdomain'])

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      domain = response[:parsed].css('resData chkData cd name').first
      expect(domain.text).to eq('one.ee')
      expect(domain[:avail]).to eq('1')

      domain = response[:parsed].css('resData chkData cd').last
      name = domain.css('name').first
      reason = domain.css('reason').first

      expect(name.text).to eq('notcorrectdomain')
      expect(name[:avail]).to eq('0')
      expect(reason.text).to eq('invalid format')
    end

  end
end
