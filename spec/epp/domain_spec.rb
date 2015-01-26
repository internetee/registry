require 'rails_helper'

describe 'EPP Domain', epp: true do
  let(:server_zone) { Epp::Server.new({ server: 'localhost', tag: 'zone', password: 'ghyt9e4fu', port: 701 }) }
  let(:server_elkdata) { Epp::Server.new({ server: 'localhost', tag: 'elkdata', password: 'ghyt9e4fu', port: 701 }) }
  let(:epp_xml) { EppXml.new(cl_trid: 'ABC-12345') }

  before(:each) { create_settings }

  before(:all) do
    @elkdata = Fabricate(:registrar, { name: 'Elkdata', reg_no: '123' })
    @zone = Fabricate(:registrar)
    Fabricate(:epp_user, username: 'zone', registrar: @zone)
    Fabricate(:epp_user, username: 'elkdata', registrar: @elkdata)

    Contact.skip_callback(:create, :before, :generate_code)

    Fabricate(:contact, code: 'citizen_1234')
    Fabricate(:contact, code: 'sh8013')
    Fabricate(:contact, code: 'sh801333')
    Fabricate(:contact, code: 'juridical_1234', ident_type: 'ico')
    Fabricate(:reserved_domain)

    @uniq_no = proc { @i ||= 0; @i += 1 }
  end

  it 'returns error if contact does not exists' do
    response = epp_request(domain_create_xml({
      registrant: { value: 'citizen_1234' },
      _anonymus: [
        { contact: { value: 'citizen_1234', attrs: { type: 'admin' } } },
        { contact: { value: 'sh1111', attrs: { type: 'tech' } } },
        { contact: { value: 'sh2222', attrs: { type: 'tech' } } }
      ]
    }), :xml)

    expect(response[:results][0][:result_code]).to eq('2303')
    expect(response[:results][0][:msg]).to eq('Contact was not found')
    expect(response[:results][0][:value]).to eq('sh1111')

    expect(response[:results][1][:result_code]).to eq('2303')
    expect(response[:results][1][:msg]).to eq('Contact was not found')
    expect(response[:results][1][:value]).to eq('sh2222')

    expect(response[:clTRID]).to eq('ABC-12345')

    log = ApiLog::EppLog.last(4)

    expect(log.length).to eq(4)
    expect(log[0].request_command).to eq('hello')
    expect(log[0].request_successful).to eq(true)

    expect(log[1].request_command).to eq('login')
    expect(log[1].request_successful).to eq(true)
    expect(log[1].api_user_name).to eq('zone')
    expect(log[1].api_user_registrar).to eq('Registrar OÜ')

    expect(log[2].request_command).to eq('create')
    expect(log[2].request_object).to eq('domain')
    expect(log[2].request_successful).to eq(false)
    expect(log[2].api_user_name).to eq('zone')
    expect(log[2].api_user_registrar).to eq('Registrar OÜ')
    expect(log[2].request).not_to be_blank
    expect(log[2].response).not_to be_blank

    expect(log[3].request_command).to eq('logout')
    expect(log[3].request_successful).to eq(true)
    expect(log[3].api_user_name).to eq('zone')
    expect(log[3].api_user_registrar).to eq('Registrar OÜ')
  end

  it 'validates required parameters' do
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    xml = epp_xml.create({
      name: { value: 'test.ee' }
    })

    response = epp_request(xml, :xml)
    expect(response[:results][0][:result_code]).to eq('2003')
    expect(response[:results][0][:msg]).to eq('Required parameter missing: ns')

    expect(response[:results][1][:result_code]).to eq('2003')
    expect(response[:results][1][:msg]).to eq('Required parameter missing: registrant')

    expect(response[:results][2][:result_code]).to eq('2003')
    expect(response[:results][2][:msg]).to eq('Required parameter missing: ns > hostAttr')

    expect(response[:results][3][:result_code]).to eq('2003')
    expect(response[:results][3][:msg]).to eq('Required parameter missing: extension > extdata > legalDocument')
  end

  context 'with citizen as an owner' do
    it 'creates a domain' do
      dn = next_domain_name
      response = epp_request(domain_create_xml({
        name: { value: dn }
      }), :xml)
      d = Domain.last
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      cre_data = response[:parsed].css('creData')

      expect(cre_data.css('name').text).to eq(dn)
      expect(cre_data.css('crDate').text).to eq(d.created_at.to_time.utc.to_s)
      expect(cre_data.css('exDate').text).to eq(d.valid_to.to_time.utc.to_s)

      expect(response[:clTRID]).to eq('ABC-12345')

      expect(d.registrar.name).to eq('Registrar OÜ')
      expect(d.tech_contacts.count).to eq 2
      expect(d.admin_contacts.count).to eq 1

      expect(d.nameservers.count).to eq(2)
      expect(d.auth_info).not_to be_empty

      expect(d.dnskeys.count).to eq(1)

      key = d.dnskeys.last

      expect(key.ds_alg).to eq(3)
      expect(key.ds_key_tag).to_not be_blank

      expect(key.ds_digest_type).to eq(Setting.ds_algorithm)
      expect(key.flags).to eq(257)
      expect(key.protocol).to eq(3)
      expect(key.alg).to eq(5)
      expect(key.public_key).to eq('AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8')
    end

    it 'creates a domain with legal document' do
      response = epp_request(domain_create_xml_with_legal_doc, :xml)

      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:result_code]).to eq('1000')
      d = Domain.last
      expect(d.legal_documents.count).to eq(1)
    end

    it 'creates ria.ee with valid ds record' do
      xml = domain_create_xml({
        name: { value: 'ria.ee' }
      }, {
        _anonymus: [
          { keyData: {
              flags: { value: '257' },
              protocol: { value: '3' },
              alg: { value: '8' },
              pubKey: { value: 'AwEAAaOf5+lz3ftsL+0CCvfJbhUF/NVsNh8BKo61oYs5fXVbuWDiH872 '\
                'LC8uKDO92TJy7Q4TF9XMAKMMlf1GMAxlRspD749SOCTN00sqfWx1OMTu '\
                'a28L1PerwHq7665oDJDKqR71btcGqyLKhe2QDvCdA0mENimF1NudX1BJ '\
                'DDFi6oOZ0xE/0CuveB64I3ree7nCrwLwNs56kXC4LYoX3XdkOMKiJLL/ '\
                'MAhcxXa60CdZLoRtTEW3z8/oBq4hEAYMCNclpbd6y/exScwBxFTdUfFk '\
                'KsdNcmvai1lyk9vna0WQrtpYpHKMXvY9LFHaJxCOLR4umfeQ42RuTd82 lqfU6ClMeXs=' }
            }
          }
        ]
      })

      epp_request(xml, :xml)
      d = Domain.last
      ds = d.dnskeys.last
      expect(ds.ds_digest).to eq('0B62D1BC64EFD1EE652FB102BDF1011BF514CCD9A1A0CFB7472AEA3B01F38C92')
    end

    it 'validates nameserver ipv4 when in same zone as domain' do
      dn = next_domain_name
      xml = domain_create_xml({
        name: { value: dn },
        ns: [
          {
            hostAttr: [
              { hostName: { value: "ns1.#{dn}" } }
            ]
          },
          {
            hostAttr: {
              hostName: { value: "ns2.#{dn}" }
            }
          }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2306')
      expect(response[:msg]).to eq('IPv4 is missing')
    end

    it 'does not create duplicate domain' do
      dn = next_domain_name
      epp_request(domain_create_xml({
        name: { value: dn }
      }), :xml)
      response = epp_request(domain_create_xml({
        name: { value: dn }
      }), :xml)

      expect(response[:result_code]).to eq('2302')
      expect(response[:msg]).to eq('Domain name already exists')
      expect(response[:clTRID]).to eq('ABC-12345')
    end

    it 'does not create reserved domain' do
      xml = domain_create_xml(name: { value: '1162.ee' })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2302')
      expect(response[:msg]).to eq('Domain name is reserved or restricted')
      expect(response[:clTRID]).to eq('ABC-12345')
    end

    it 'does not create domain without contacts and registrant' do
      xml = domain_create_xml(contacts: [], registrant: false)

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('2003')
      expect(response[:results][0][:msg]).to eq('Required parameter missing: registrant')
    end

    it 'does not create domain without nameservers' do
      xml = domain_create_xml(ns: [])
      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2003')
      expect(response[:msg]).to eq('Required parameter missing: ns')
    end

    it 'does not create domain with too many nameservers' do
      nameservers = []
      14.times do |i|
        nameservers << {
          hostAttr: {
            hostName: { value: "ns#{i}.example.net" }
          }
        }
      end

      xml = domain_create_xml({
        ns: nameservers
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2004')
      expect(response[:msg]).to eq('Nameservers count must be between 2-11')
    end

    it 'returns error when invalid nameservers are present' do
      xml = domain_create_xml({
        ns: [
          {
            hostAttr: {
              hostName: { value: 'invalid1-' }
            }
          },
          {
            hostAttr: {
              hostName: { value: '-invalid2' }
            }
          }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2005')
      expect(response[:msg]).to eq('Hostname is invalid')
    end

    it 'checks hostAttr presence' do
      xml = domain_create_xml({
        ns: [
          {
            hostObj: { value: 'ns1.example.ee' }
          },
          {
            hostObj: { value: 'ns2.example.ee' }
          }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2003')
      expect(response[:msg]).to eq('Required parameter missing: ns > hostAttr')
    end

    it 'creates domain with nameservers with ips' do
      epp_request(domain_create_with_host_attrs, :xml)
      expect(Domain.last.nameservers.count).to eq(2)
      ns = Domain.last.nameservers.first
      expect(ns.ipv4).to eq('192.0.2.2')
      expect(ns.ipv6).to eq('1080:0:0:0:8:800:200C:417A')
    end

    it 'returns error when nameserver has invalid ips' do
      domain_count = Domain.count
      nameserver_count = Nameserver.count
      response = epp_request(domain_create_with_invalid_ns_ip_xml, :xml)
      expect(response[:results][0][:result_code]).to eq '2005'
      expect(response[:results][0][:msg]).to eq 'IPv4 is invalid'
      expect(response[:results][0][:value]).to eq '192.0.2.2.invalid'
      expect(response[:results][1][:result_code]).to eq '2005'
      expect(response[:results][1][:msg]).to eq 'IPv6 is invalid'
      expect(response[:results][1][:value]).to eq 'INVALID_IPV6'
      # ensure nothing gets saved to db:
      expect(Domain.count).to eq(domain_count)
      expect(Nameserver.count).to eq(nameserver_count)
    end

    it 'creates a domain with period in days' do
      xml = domain_create_xml(period_value: 365, period_unit: 'd')

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(Domain.first.valid_to).to eq(Date.today + 1.year)
    end

    it 'does not create a domain with invalid period' do
      xml = domain_create_xml({
        period: { value: '367', attrs: { unit: 'd' } }
      })

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('2004')
      expect(response[:results][0][:msg]).to eq('Period must add up to 1, 2 or 3 years')
      expect(response[:results][0][:value]).to eq('367')
    end

    it 'creates a domain with multiple dnskeys' do
      xml = domain_create_xml({}, {
        _anonymus: [
          { keyData: {
              flags: { value: '257' },
              protocol: { value: '3' },
              alg: { value: '3' },
              pubKey: { value: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8' }
            }
          },
          {
            keyData: {
              flags: { value: '0' },
              protocol: { value: '3' },
              alg: { value: '5' },
              pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
            }
          },
          {
            keyData: {
              flags: { value: '256' },
              protocol: { value: '3' },
              alg: { value: '254' },
              pubKey: { value: '841936717ae427ace63c28d04918569a841936717ae427ace63c28d0' }
            }
          }
        ]
      })

      epp_request(xml, :xml)
      d = Domain.last

      expect(d.dnskeys.count).to eq(3)

      key_1 = d.dnskeys[0]
      expect(key_1.ds_key_tag).to_not be_blank
      expect(key_1.ds_alg).to eq(3)
      expect(key_1.ds_digest_type).to eq(Setting.ds_algorithm)

      expect(d.dnskeys.pluck(:flags)).to match_array([257, 0, 256])
      expect(d.dnskeys.pluck(:protocol)).to match_array([3, 3, 3])
      expect(d.dnskeys.pluck(:alg)).to match_array([3, 5, 254])
      expect(d.dnskeys.pluck(:public_key)).to match_array(%w(
        AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8
        700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f
        841936717ae427ace63c28d04918569a841936717ae427ace63c28d0
      ))
    end

    it 'does not create a domain when dnskeys are invalid' do

      xml = domain_create_xml({}, {
       _anonymus: [
         { keyData: {
             flags: { value: '250' },
             protocol: { value: '4' },
             alg: { value: '9' },
             pubKey: { value: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8' }
           }
         },
         {
           keyData: {
             flags: { value: '1' },
             protocol: { value: '3' },
             alg: { value: '10' },
             pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
           }
         },
         {
           keyData: {
             flags: { value: '256' },
             protocol: { value: '5' },
             alg: { value: '254' },
             pubKey: { value: '' }
           }
         }
       ]
     })

      response = epp_request(xml, :xml)

      expect(response[:results][0][:msg]).to eq('Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255')
      expect(response[:results][0][:value]).to eq('9')

      expect(response[:results][1][:msg]).to eq('Valid protocols are: 3')
      expect(response[:results][1][:value]).to eq('4')

      expect(response[:results][2][:msg]).to eq('Valid flags are: 0, 256, 257')
      expect(response[:results][2][:value]).to eq('250')

      expect(response[:results][3][:msg]).to eq('Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255')
      expect(response[:results][3][:value]).to eq('10')

      expect(response[:results][4][:msg]).to eq('Valid flags are: 0, 256, 257')
      expect(response[:results][4][:value]).to eq('1')

      expect(response[:results][5][:msg]).to eq('Public key is missing')

      expect(response[:results][6][:msg]).to eq('Valid protocols are: 3')
      expect(response[:results][6][:value]).to eq('5')
    end

    it 'does not create a domain with two identical dnskeys' do
      xml = domain_create_xml({}, {
       _anonymus: [
         { keyData: {
             flags: { value: '257' },
             protocol: { value: '3' },
             alg: { value: '3' },
             pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
           }
         },
         {
           keyData: {
             flags: { value: '0' },
             protocol: { value: '3' },
             alg: { value: '5' },
             pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
           }
         }]
       })

      response = epp_request(xml, :xml)

      expect(response[:result_code]).to eq('2302')
      expect(response[:msg]).to eq('Public key already exists')
      expect(response[:results][0][:value]).to eq('700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f')
    end

    it 'validated dnskeys count' do
      Setting.dnskeys_max_count = 1

      xml = domain_create_xml({}, {
      _anonymus: [
        { keyData: {
            flags: { value: '257' },
            protocol: { value: '3' },
            alg: { value: '3' },
            pubKey: { value: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8' }
          }
        },
        {
          keyData: {
            flags: { value: '0' },
            protocol: { value: '3' },
            alg: { value: '5' },
            pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
          }
        }]
      })

      response = epp_request(xml, :xml)

      expect(response[:result_code]).to eq('2004')
      expect(response[:msg]).to eq('DNS keys count must be between 0-1')
    end

    it 'creates domain with ds data' do
      xml = domain_create_xml({}, {
        _anonymus: [
          { dsData: {
              keyTag: { value: '12345' },
              alg: { value: '3' },
              digestType: { value: '1' },
              digest: { value: '49FD46E6C4B45C55D4AC' }
            }
          }]
        })

      epp_request(xml, :xml)

      d = Domain.last
      ds = d.dnskeys.first
      expect(ds.ds_key_tag).to eq('12345')
      expect(ds.ds_alg).to eq(3)
      expect(ds.ds_digest_type).to eq(1)
      expect(ds.ds_digest).to eq('49FD46E6C4B45C55D4AC')
      expect(ds.flags).to be_nil
      expect(ds.protocol).to be_nil
      expect(ds.alg).to be_nil
      expect(ds.public_key).to be_nil
    end

    it 'creates domain with ds data with key' do
      xml = domain_create_xml({}, {
        _anonymus: [
          { dsData: {
              keyTag: { value: '12345' },
              alg: { value: '3' },
              digestType: { value: '1' },
              digest: { value: '49FD46E6C4B45C55D4AC' },
              keyData: {
                flags: { value: '0' },
                protocol: { value: '3' },
                alg: { value: '5' },
                pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
              }
            }
          }]
        })

      epp_request(xml, :xml)

      d = Domain.last
      ds = d.dnskeys.first
      expect(ds.ds_key_tag).to eq('12345')
      expect(ds.ds_alg).to eq(3)
      expect(ds.ds_digest_type).to eq(1)
      expect(ds.ds_digest).to eq('49FD46E6C4B45C55D4AC')
      expect(ds.flags).to eq(0)
      expect(ds.protocol).to eq(3)
      expect(ds.alg).to eq(5)
      expect(ds.public_key).to eq('700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f')
    end

    it 'prohibits dsData with key' do
      Setting.ds_data_with_key_allowed = false

      xml = domain_create_xml({}, {
        _anonymus: [
          { dsData: {
              keyTag: { value: '12345' },
              alg: { value: '3' },
              digestType: { value: '1' },
              digest: { value: '49FD46E6C4B45C55D4AC' },
              keyData: {
                flags: { value: '0' },
                protocol: { value: '3' },
                alg: { value: '5' },
                pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
              }
            }
          }]
        })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2306')
      expect(response[:msg]).to eq('dsData object with key data is not allowed')
    end

    it 'prohibits dsData' do
      Setting.ds_data_allowed = false

      xml = domain_create_xml({}, {
        _anonymus: [
          { dsData: {
              keyTag: { value: '12345' },
              alg: { value: '3' },
              digestType: { value: '1' },
              digest: { value: '49FD46E6C4B45C55D4AC' },
              keyData: {
                flags: { value: '0' },
                protocol: { value: '3' },
                alg: { value: '5' },
                pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
              }
            }
          }]
        })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2306')
      expect(response[:msg]).to eq('dsData object is not allowed')
    end

    it 'prohibits keyData' do
      Setting.key_data_allowed = false

      xml = domain_create_xml({}, {
        _anonymus: [
          keyData: {
            flags: { value: '0' },
            protocol: { value: '3' },
            alg: { value: '5' },
            pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
          }]
        })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2306')
      expect(response[:msg]).to eq('keyData object is not allowed')
    end
  end

  context 'with juridical persion as an owner' do
    it 'creates a domain with contacts' do
      xml = domain_create_xml({
        registrant: { value: 'juridical_1234' },
        _anonymus: [
          { contact: { value: 'sh8013', attrs: { type: 'admin' } } }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:clTRID]).to eq('ABC-12345')

      expect(Domain.last.tech_contacts.count).to eq 1
      expect(Domain.last.admin_contacts.count).to eq 1

      tech_contact = Domain.last.tech_contacts.first
      expect(tech_contact.code).to eq('juridical_1234')
    end

    it 'does not create a domain without admin contact' do
      domain_count = Domain.count
      domain_contact_count = DomainContact.count
      xml = domain_create_xml({
        registrant: { value: 'juridical_1234' },
        _anonymus: [
          { contact: { value: 'sh8013', attrs: { type: 'tech' } } }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2004')
      expect(response[:msg]).to eq('Admin contacts count must be between 1-10')
      expect(response[:clTRID]).to eq('ABC-12345')

      expect(Domain.count).to eq domain_count
      expect(DomainContact.count).to eq domain_contact_count
    end

    it 'cannot assign juridical person as admin contact' do
      xml = domain_create_xml({
        registrant: { value: 'juridical_1234' },
        _anonymus: [
          { contact: { value: 'juridical_1234', attrs: { type: 'admin' } } }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2306')
      expect(response[:msg]).to eq('Admin contact can be only citizen')
    end
  end

  context 'with valid domain' do
    before(:each) { Fabricate(:domain, name: next_domain_name, registrar: @zone, dnskeys: []) }
    let(:domain) { Domain.last }

    ### TRANSFER ###
    it 'transfers a domain' do
      domain.registrar = @zone
      domain.save

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })
      response = epp_request(xml, :xml, :elkdata)

      domain.reload
      dtl = domain.domain_transfers.last

      trn_data = response[:parsed].css('trnData')
      expect(trn_data.css('name').text).to eq(domain.name)
      expect(trn_data.css('trStatus').text).to eq('serverApproved')
      expect(trn_data.css('reID').text).to eq('123')
      expect(trn_data.css('reDate').text).to eq(dtl.transfer_requested_at.to_time.utc.to_s)
      expect(trn_data.css('acID').text).to eq('12345678')
      expect(trn_data.css('acDate').text).to eq(dtl.transferred_at.to_time.utc.to_s)
      expect(trn_data.css('exDate').text).to eq(domain.valid_to.to_time.utc.to_s)

      expect(domain.registrar).to eq(@elkdata)

      Setting.transfer_wait_time = 1

      domain.reload
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }) # request with new password

      response = epp_request(xml, :xml, :zone)
      trn_data = response[:parsed].css('trnData')

      domain.reload
      dtl = domain.domain_transfers.last

      expect(domain.domain_transfers.count).to eq(2)

      expect(trn_data.css('name').text).to eq(domain.name)
      expect(trn_data.css('trStatus').text).to eq('pending')
      expect(trn_data.css('reID').text).to eq('12345678')
      expect(trn_data.css('reDate').text).to eq(dtl.transfer_requested_at.to_time.utc.to_s)
      expect(trn_data.css('acDate').text).to eq(dtl.wait_until.to_time.utc.to_s)
      expect(trn_data.css('acID').text).to eq('123')
      expect(trn_data.css('exDate').text).to eq(domain.valid_to.to_time.utc.to_s)

      expect(domain.registrar).to eq(@elkdata)

      # should return same data if pending already
      response = epp_request(xml, :xml, :zone)
      trn_data = response[:parsed].css('trnData')

      expect(domain.domain_transfers.count).to eq(2)
      expect(trn_data.css('name').text).to eq(domain.name)
      expect(trn_data.css('trStatus').text).to eq('pending')
      expect(trn_data.css('reID').text).to eq('12345678')
      expect(trn_data.css('reDate').text).to eq(dtl.transfer_requested_at.to_time.utc.to_s)
      expect(trn_data.css('acDate').text).to eq(dtl.wait_until.to_time.utc.to_s)
      expect(trn_data.css('acID').text).to eq('123')
      expect(trn_data.css('exDate').text).to eq(domain.valid_to.to_time.utc.to_s)

      expect(domain.registrar).to eq(@elkdata)

      # should show up in other registrar's poll

      response = epp_request(epp_xml.session.poll, :xml, :elkdata)
      expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
      msg_q = response[:parsed].css('msgQ')
      expect(msg_q.css('qDate').text).to_not be_blank
      expect(msg_q.css('msg').text).to eq('Transfer requested.')
      expect(msg_q.first['id']).to_not be_blank
      expect(msg_q.first['count']).to eq('1')

      xml = epp_xml.session.poll(poll: {
        value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
      })

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:msg]).to eq('Command completed successfully')
      msg_q = response[:parsed].css('msgQ')
      expect(msg_q.first['id']).to_not be_blank
      expect(msg_q.first['count']).to eq('0')
    end

    it 'creates a domain transfer with legal document' do
      Setting.transfer_wait_time = 1
      expect(domain.legal_documents.count).to eq(0)
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }, 'query', {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = epp_request(xml, :xml, :elkdata)

      expect(response[:result_code]).to eq('1000')
      expect(domain.legal_documents.count).to eq(1)

      log = ApiLog::EppLog.last(4)

      expect(log[0].request_command).to eq('hello')
      expect(log[0].request_successful).to eq(true)

      expect(log[1].request_command).to eq('login')
      expect(log[1].request_successful).to eq(true)
      expect(log[1].api_user_name).to eq('elkdata')
      expect(log[1].api_user_registrar).to eq('Elkdata')

      expect(log[2].request_command).to eq('transfer')
      expect(log[2].request_object).to eq('domain')
      expect(log[2].request_successful).to eq(true)
      expect(log[2].api_user_name).to eq('elkdata')
      expect(log[2].api_user_registrar).to eq('Elkdata')
      expect(log[2].request).not_to be_blank
      expect(log[2].response).not_to be_blank

      expect(log[3].request_command).to eq('logout')
      expect(log[3].request_successful).to eq(true)
      expect(log[3].api_user_name).to eq('elkdata')
      expect(log[3].api_user_registrar).to eq('Elkdata')

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:result_code]).to eq('1000')
      expect(domain.legal_documents.count).to eq(1) # does not add another legal document
    end

    it 'approves the transfer request' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: @elkdata,
        transfer_from: @zone
      })

      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: domain.auth_info } }
      }, 'approve')
      response = epp_request(xml, :xml, :zone)
      domain.reload
      dtl = domain.domain_transfers.last

      trn_data = response[:parsed].css('trnData')

      expect(trn_data.css('name').text).to eq(domain.name)
      expect(trn_data.css('trStatus').text).to eq('clientApproved')
      expect(trn_data.css('reID').text).to eq('123')
      expect(trn_data.css('reDate').text).to eq(dtl.transfer_requested_at.to_time.utc.to_s)
      expect(trn_data.css('acID').text).to eq('12345678')
      expect(trn_data.css('exDate').text).to eq(domain.valid_to.to_time.utc.to_s)
    end

    it 'rejects a domain transfer' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: @elkdata,
        transfer_from: @zone
      })

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }, 'reject', {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:msg]).to eq('Transfer can be rejected only by current registrar')
      expect(response[:result_code]).to eq('2304')
      expect(domain.legal_documents.count).to eq(0)

      response = epp_request(xml, :xml, :zone)
      expect(response[:result_code]).to eq('1000')
      expect(domain.pending_transfer).to be_nil
      expect(domain.legal_documents.count).to eq(1)
    end

    it 'prohibits wrong registrar from approving transfer' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: @elkdata,
        transfer_from: @zone
      })

      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: domain.auth_info } }
      }, 'approve')

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:result_code]).to eq('2304')
      expect(response[:msg]).to eq('Transfer can be approved only by current domain registrar')
    end

    it 'does not transfer with invalid pw' do
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: 'test' } }
      })
      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('2201')
      expect(response[:msg]).to eq('Authorization error')
    end

    it 'ignores transfer when owner registrar requests transfer' do
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })
      response = epp_request(xml, :xml, :zone)

      expect(response[:result_code]).to eq('2002')
      expect(response[:msg]).to eq('Domain already belongs to the querying registrar')
    end

    it 'returns an error for incorrect op attribute' do
      response = epp_request(domain_transfer_xml({}, 'bla'), :xml, :zone)
      expect(response[:result_code]).to eq('2306')
      expect(response[:msg]).to eq('Attribute op is invalid')
    end

    it 'creates new pw after successful transfer' do
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      epp_request(xml, :xml, :elkdata) # transfer domain
      response = epp_request(xml, :xml, :elkdata) # attempt second transfer
      expect(response[:result_code]).to eq('2201')
      expect(response[:msg]).to eq('Authorization error')
    end

    ### UPDATE ###
    it 'updates a domain' do
      existing_pw = Domain.last.auth_info

      xml_params = {
        name: { value: domain.name },
        chg: [
          registrant: { value: 'citizen_1234' }
        ]
      }

      response = epp_request(domain_update_xml(xml_params, {}, {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          }
        ]
      }), :xml)

      expect(response[:results][0][:result_code]).to eq('1000')

      d = Domain.last

      expect(d.owner_contact_code).to eq('citizen_1234')
      expect(d.auth_info).to eq(existing_pw)
    end

    it 'updates domain and adds objects' do
      xml = domain_update_xml({
        name: { value: domain.name },
        add: [
          {
            ns: [
              {
                hostAttr: [
                  { hostName: { value: 'ns1.example.com' } }
                ]
              },
              {
                hostAttr: [
                  { hostName: { value: 'ns2.example.com' } }
                ]
              }
            ]
          },
          _anonymus: [
            { contact: { value: 'mak21', attrs: { type: 'tech' } } },
            { status: { value: 'Payment overdue.', attrs: { s: 'clientHold', lang: 'en' } } },
            { status: { value: '', attrs: { s: 'clientUpdateProhibited' } } }
          ]
        ]
      }, {
        add: [
          { keyData: {
              flags: { value: '0' },
              protocol: { value: '3' },
              alg: { value: '5' },
              pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
            }
          },
          {
            keyData: {
              flags: { value: '256' },
              protocol: { value: '3' },
              alg: { value: '254' },
              pubKey: { value: '841936717ae427ace63c28d04918569a841936717ae427ace63c28d0' }
            }
          }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('2303')
      expect(response[:results][0][:msg]).to eq('Contact was not found')

      Fabricate(:contact, code: 'mak21')

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('1000')

      d = Domain.last

      new_ns_count = d.nameservers.where(hostname: ['ns1.example.com', 'ns2.example.com']).count
      expect(new_ns_count).to eq(2)

      new_contact = d.tech_contacts.find_by(code: 'mak21')
      expect(new_contact).to be_truthy

      expect(d.domain_statuses.count).to eq(2)
      expect(d.domain_statuses.first.description).to eq('Payment overdue.')
      expect(d.domain_statuses.first.value).to eq('clientHold')

      expect(d.domain_statuses.last.value).to eq('clientUpdateProhibited')
      expect(d.dnskeys.count).to eq(2)

      response = epp_request(xml, :xml)

      expect(response[:results][0][:result_code]).to eq('2302')
      expect(response[:results][0][:msg]).to eq('Nameserver already exists on this domain')
      expect(response[:results][0][:value]).to eq('ns1.example.com')

      expect(response[:results][1][:result_code]).to eq('2302')
      expect(response[:results][1][:msg]).to eq('Nameserver already exists on this domain')
      expect(response[:results][1][:value]).to eq('ns2.example.com')

      expect(response[:results][2][:result_code]).to eq('2302')
      expect(response[:results][2][:msg]).to eq('Contact already exists on this domain')
      expect(response[:results][2][:value]).to eq('mak21')

      expect(response[:results][3][:msg]).to eq('Status already exists on this domain')
      expect(response[:results][3][:value]).to eq('clientHold')

      expect(response[:results][4][:msg]).to eq('Status already exists on this domain')
      expect(response[:results][4][:value]).to eq('clientUpdateProhibited')

      expect(response[:results][5][:msg]).to eq('Public key already exists')
      expect(response[:results][5][:value]).to eq('700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f')

      expect(response[:results][6][:msg]).to eq('Public key already exists')
      expect(response[:results][6][:value]).to eq('841936717ae427ace63c28d04918569a841936717ae427ace63c28d0')

      expect(d.domain_statuses.count).to eq(2)
    end

    it 'updates a domain and removes objects' do
      xml = domain_update_xml({
        name: { value: domain.name },
        add: [
          {
            ns: [
              {
                hostAttr: [
                  { hostName: { value: 'ns1.example.com' } }
                ]
              },
              {
                hostAttr: [
                  { hostName: { value: 'ns2.example.com' } }
                ]
              }
            ]
          },
          _anonymus: [
            { contact: { value: 'citizen_1234', attrs: { type: 'tech' } } },
            { status: { value: 'Payment overdue.', attrs: { s: 'clientHold', lang: 'en' } } },
            { status: { value: '', attrs: { s: 'clientUpdateProhibited' } } }
          ]
        ]
      }, {
        add: [
          { keyData: {
              flags: { value: '0' },
              protocol: { value: '3' },
              alg: { value: '5' },
              pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
            }
          },
          {
            keyData: {
              flags: { value: '256' },
              protocol: { value: '3' },
              alg: { value: '254' },
              pubKey: { value: '841936717ae427ace63c28d04918569a841936717ae427ace63c28d0' }
            }
          }
        ]
      })

      epp_request(xml, :xml)
      d = Domain.last
      expect(d.dnskeys.count).to eq(2)

      xml = domain_update_xml({
        name: { value: domain.name },
        rem: [
          {
            ns: [
              {
                hostAttr: [
                  { hostName: { value: 'ns1.example.com' } }
                ]
              }
            ]
          },
          _anonymus: [
            { contact: { value: 'citizen_1234', attrs: { type: 'tech' } } },
            { status: { value: '', attrs: { s: 'clientHold' } } }
          ]
        ]
      }, {
        rem: [
          { keyData: {
              pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
            }
          }
        ]
      })

      epp_request(xml, :xml)

      expect(d.dnskeys.count).to eq(1)

      expect(d.domain_statuses.count).to eq(1)
      expect(d.domain_statuses.first.value).to eq('clientUpdateProhibited')

      rem_ns = d.nameservers.find_by(hostname: 'ns1.example.com')
      expect(rem_ns).to be_falsey

      rem_cnt = d.tech_contacts.find_by(code: 'citizen_1234')
      expect(rem_cnt).to be_falsey

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('2303')
      expect(response[:results][0][:msg]).to eq('Contact was not found')
      expect(response[:results][0][:value]).to eq('citizen_1234')

      expect(response[:results][1][:result_code]).to eq('2303')
      expect(response[:results][1][:msg]).to eq('Nameserver was not found')
      expect(response[:results][1][:value]).to eq('ns1.example.com')

      expect(response[:results][2][:result_code]).to eq('2303')
      expect(response[:results][2][:msg]).to eq('Status was not found')
      expect(response[:results][2][:value]).to eq('clientHold')
    end

    it 'does not remove server statuses' do
      d = Domain.last
      d.domain_statuses.create(value: DomainStatus::SERVER_HOLD)

      xml = domain_update_xml({
        name: { value: domain.name },
        rem: [
          _anonymus: [
            { status: { value: '', attrs: { s: 'serverHold' } } }
          ]
        ]
      })

      response = epp_request(xml, :xml)

      expect(response[:results][0][:result_code]).to eq('2303')
      expect(response[:results][0][:msg]).to eq('Status was not found')
      expect(response[:results][0][:value]).to eq('serverHold')
    end

    it 'does not add duplicate objects to domain' do
      d = Domain.last
      c = d.admin_contacts.first
      n = d.nameservers.first

      xml = domain_update_xml({
        name: { value: domain.name },
        add: {
          ns: [
            {
              hostAttr: [
                { hostName: { value: n.hostname } }
              ]
            }
          ],
          _anonymus: [
            { contact: { value: c.code, attrs: { type: 'admin' } } }
          ]
        }
      })

      epp_request(xml, :xml)
      response = epp_request(xml, :xml)

      expect(response[:results][0][:result_code]).to eq('2302')
      expect(response[:results][0][:msg]).to eq('Nameserver already exists on this domain')
      expect(response[:results][0][:value]).to eq(n.hostname)

      expect(response[:results][1][:result_code]).to eq('2302')
      expect(response[:results][1][:msg]).to eq('Contact already exists on this domain')
      expect(response[:results][1][:value]).to eq(c.code)
    end

    it 'cannot change registrant without legal document' do
      xml_params = {
        name: { value: domain.name },
        chg: [
          registrant: { value: 'citizen_1234' }
        ]
      }

      response = epp_request(domain_update_xml(xml_params), :xml)
      expect(response[:results][0][:msg]).to eq('Required parameter missing: extension > extdata > legalDocument')
      expect(response[:results][0][:result_code]).to eq('2003')
    end

    it 'does not assign invalid status to domain' do
      xml = domain_update_xml({
        name: { value: domain.name },
        add: [
          status: { value: '', attrs: { s: 'invalidStatus' } }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('2303')
      expect(response[:results][0][:msg]).to eq('Status was not found')
      expect(response[:results][0][:value]).to eq('invalidStatus')
    end

    ### RENEW ###
    it 'renews a domain' do
      exp_date = (Date.today + 1.year)
      xml = epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_request(xml, :xml)
      ex_date = response[:parsed].css('renData exDate').text
      name = response[:parsed].css('renData name').text
      expect(ex_date).to eq("#{(exp_date + 1.year)} 00:00:00 UTC")
      expect(name).to eq(domain.name)
    end

    it 'returns an error when given and current exp dates do not match' do
      xml = epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: '2200-08-07' },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('2306')
      expect(response[:results][0][:msg]).to eq('Given and current expire dates do not match')
    end

    it 'returns an error when period is invalid' do
      exp_date = (Date.today + 1.year)

      xml = epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '4', attrs: { unit: 'y' } }
      )

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('2004')
      expect(response[:results][0][:msg]).to eq('Period must add up to 1, 2 or 3 years')
      expect(response[:results][0][:value]).to eq('4')
    end

    ### INFO ###
    it 'returns domain info' do
      domain.domain_statuses.build(value: DomainStatus::CLIENT_HOLD, description: 'Payment overdue.')
      domain.nameservers.build(hostname: 'ns1.example.com', ipv4: '192.168.1.1', ipv6: '1080:0:0:0:8:800:200C:417A')

      domain.dnskeys.build(
        ds_key_tag: '123',
        ds_alg: 3,
        ds_digest_type: 1,
        ds_digest: 'abc',
        flags: 257,
        protocol: 3,
        alg: 3,
        public_key: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8'
      )

      domain.dnskeys.build(
        ds_key_tag: '123',
        ds_alg: 3,
        ds_digest_type: 1,
        ds_digest: 'abc',
        flags: 0,
        protocol: 3,
        alg: 5,
        public_key: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'
      )

      domain.save

      xml = domain_info_xml(name: { value: domain.name })

      response = epp_request(xml, :xml)
      expect(response[:results][0][:result_code]).to eq('1000')
      expect(response[:results][0][:msg]).to eq('Command completed successfully')

      inf_data = response[:parsed].css('resData infData')
      expect(inf_data.css('name').text).to eq(domain.name)
      expect(inf_data.css('status').text).to eq('Payment overdue.')
      expect(inf_data.css('status').first[:s]).to eq('clientHold')
      expect(inf_data.css('registrant').text).to eq(domain.owner_contact_code)

      admin_contacts_from_request = inf_data.css('contact[type="admin"]').map(&:text)
      admin_contacts_existing = domain.admin_contacts.pluck(:code)

      expect(admin_contacts_from_request).to eq(admin_contacts_existing)

      hosts_from_request = inf_data.css('hostName').map(&:text)
      hosts_existing = domain.nameservers.pluck(:hostname)

      expect(hosts_from_request).to eq(hosts_existing)

      ns1 = inf_data.css('hostAttr').last

      expect(ns1.css('hostName').last.text).to eq('ns1.example.com')
      expect(ns1.css('hostAddr').first.text).to eq('192.168.1.1')
      expect(ns1.css('hostAddr').last.text).to eq('1080:0:0:0:8:800:200C:417A')
      expect(inf_data.css('crDate').text).to eq(domain.created_at.to_time.utc.to_s)
      expect(inf_data.css('exDate').text).to eq(domain.valid_to.to_time.utc.to_s)
      expect(inf_data.css('pw').text).to eq(domain.auth_info)

      ds_data_1 = response[:parsed].css('dsData')[0]

      expect(ds_data_1.css('keyTag').first.text).to eq('123')
      expect(ds_data_1.css('alg').first.text).to eq('3')
      expect(ds_data_1.css('digestType').first.text).to eq('1')
      expect(ds_data_1.css('digest').first.text).to eq('abc')

      dnskey_1 = ds_data_1.css('keyData')[0]
      expect(dnskey_1.css('flags').first.text).to eq('257')
      expect(dnskey_1.css('protocol').first.text).to eq('3')
      expect(dnskey_1.css('alg').first.text).to eq('3')
      expect(dnskey_1.css('pubKey').first.text).to eq('AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8')

      ds_data_2 = response[:parsed].css('dsData')[1]

      dnskey_2 = ds_data_2.css('keyData')[0]
      expect(dnskey_2.css('flags').first.text).to eq('0')
      expect(dnskey_2.css('protocol').first.text).to eq('3')
      expect(dnskey_2.css('alg').first.text).to eq('5')
      expect(dnskey_2.css('pubKey').first.text).to eq('700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f')

      domain.touch

      response = epp_request(domain_info_xml(name: { value: domain.name }), :xml)
      inf_data = response[:parsed].css('resData infData')

      expect(inf_data.css('upDate').text).to eq(domain.updated_at.to_time.utc.to_s)
    end

    it 'returns error when domain can not be found' do
      response = epp_request(domain_info_xml(name:  { value: 'test.ee' }), :xml)
      expect(response[:results][0][:result_code]).to eq('2303')
      expect(response[:results][0][:msg]).to eq('Domain not found')
    end

    it 'sets ok status by default' do
      response = epp_request(domain_info_xml(name: { value: domain.name }), :xml)
      inf_data = response[:parsed].css('resData infData')
      expect(inf_data.css('status').first[:s]).to eq('ok')
    end

    it 'can not see other registrar domains' do
      response = epp_request(domain_info_xml(name: { value: domain.name }), :xml, :elkdata)
      expect(response[:result_code]).to eq('2302')
      expect(response[:msg]).to eq('Domain exists but belongs to other registrar')
    end

    ### DELETE ###
    it 'deletes domain' do
      response = epp_request(epp_xml.domain.delete({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          }
        ]
      }), :xml)

      expect(response[:result_code]).to eq('1000')

      expect(Domain.find_by(name: domain.name)).to eq(nil)
    end

    it 'does not delete domain with specific status' do
      domain.domain_statuses.create(value: DomainStatus::CLIENT_DELETE_PROHIBITED)

      response = epp_request(epp_xml.domain.delete({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          }
        ]
      }), :xml)

      expect(response[:result_code]).to eq('2304')
      expect(response[:msg]).to eq('Domain status prohibits operation')
    end

    it 'does not delete domain without legal document' do
      response = epp_request(epp_xml.domain.delete(name: { value: 'example.ee' }), :xml)
      expect(response[:result_code]).to eq('2003')
      expect(response[:msg]).to eq('Required parameter missing: extension > extdata > legalDocument')
    end

    ### CHECK ###
    it 'checks a domain' do
      response = epp_request(domain_check_xml({
        _anonymus: [
          { name: { value: 'one.ee' } }
        ]
      }), :xml)

      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      res_data = response[:parsed].css('resData chkData cd name').first
      expect(res_data.text).to eq('one.ee')
      expect(res_data[:avail]).to eq('1')

      response = epp_request(domain_check_xml({
        _anonymus: [
          { name: { value: domain.name } }
        ]
      }), :xml)
      res_data = response[:parsed].css('resData chkData cd').first
      name = res_data.css('name').first
      reason = res_data.css('reason').first

      expect(name.text).to eq(domain.name)
      expect(name[:avail]).to eq('0')
      expect(reason.text).to eq('in use')
    end

    it 'checks multiple domains' do
      xml = domain_check_xml({
        _anonymus: [
          { name: { value: 'one.ee' } },
          { name: { value: 'two.ee' } },
          { name: { value: 'three.ee' } }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      res_data = response[:parsed].css('resData chkData cd name').first
      expect(res_data.text).to eq('one.ee')
      expect(res_data[:avail]).to eq('1')

      res_data = response[:parsed].css('resData chkData cd name').last
      expect(res_data.text).to eq('three.ee')
      expect(res_data[:avail]).to eq('1')
    end

    it 'checks invalid format domain' do
      xml = domain_check_xml({
        _anonymus: [
          { name: { value: 'one.ee' } },
          { name: { value: 'notcorrectdomain' } }
        ]
      })

      response = epp_request(xml, :xml)
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      res_data = response[:parsed].css('resData chkData cd name').first
      expect(res_data.text).to eq('one.ee')
      expect(res_data[:avail]).to eq('1')

      res_data = response[:parsed].css('resData chkData cd').last
      name = res_data.css('name').first
      reason = res_data.css('reason').first

      expect(name.text).to eq('notcorrectdomain')
      expect(name[:avail]).to eq('0')
      expect(reason.text).to eq('invalid format')
    end

  end

end
