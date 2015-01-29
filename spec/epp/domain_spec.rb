require 'rails_helper'

describe 'EPP Domain', epp: true do
  let(:epp_xml) { EppXml.new(cl_trid: 'ABC-12345') }

  def registrar1
    @registrar1 ||= Registrar.where(reg_no: '12345678').first || Fabricate(:registrar)
  end

  def registrar2
    @registrar2 ||= Fabricate(:registrar, { name: 'registrar2', reg_no: '123' })
  end

  before(:all) do
    Fabricate(:epp_user, username: 'registrar1', registrar: registrar1)
    Fabricate(:epp_user, username: 'registrar2', registrar: registrar2)

    login_as :registrar1

    Contact.skip_callback(:create, :before, :generate_code)

    Fabricate(:contact, code: 'citizen_1234')
    Fabricate(:contact, code: 'sh8013')
    Fabricate(:contact, code: 'sh801333')
    Fabricate(:contact, code: 'juridical_1234', ident_type: 'ico')
    Fabricate(:reserved_domain)

    @uniq_no = proc { @i ||= 0; @i += 1 }

    create_settings
  end

  it 'returns error if contact does not exists' do
    response = epp_plain_request(domain_create_xml({
      registrant: { value: 'citizen_1234' },
      _anonymus: [
        { contact: { value: 'citizen_1234', attrs: { type: 'admin' } } },
        { contact: { value: 'sh1111', attrs: { type: 'tech' } } },
        { contact: { value: 'sh2222', attrs: { type: 'tech' } } }
      ]
    }), :xml)

    response[:results][0][:result_code].should == '2303'
    response[:results][0][:msg].should == 'Contact was not found'
    response[:results][0][:value].should == 'sh1111'

    response[:results][1][:result_code].should == '2303'
    response[:results][1][:msg].should == 'Contact was not found'
    response[:results][1][:value].should == 'sh2222'

    response[:clTRID].should == 'ABC-12345'

    log = ApiLog::EppLog.last

    log.request_command.should == 'create'
    log.request_object.should == 'domain'
    log.request_successful.should == false
    log.api_user_name.should == 'registrar1'
    log.api_user_registrar.should == 'Registrar OÜ'
    log.request.should_not be_blank
    log.response.should_not be_blank
  end

  it 'validates required parameters' do
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    xml = epp_xml.create({
      name: { value: 'test.ee' }
    })

    response = epp_plain_request(xml, :xml)
    response[:results][0][:result_code].should == '2003'
    response[:results][0][:msg].should == 'Required parameter missing: create > create > ns'

    response[:results][1][:result_code].should == '2003'
    response[:results][1][:msg].should == 'Required parameter missing: create > create > registrant'

    response[:results][2][:result_code].should == '2003'
    response[:results][2][:msg].should == 'Required parameter missing: create > create > ns > hostAttr'

    response[:results][3][:result_code].should == '2003'
    response[:results][3][:msg].should == 'Required parameter missing: extension > extdata > legalDocument'
  end

  context 'with citizen as an owner' do
    it 'creates a domain' do
      dn = next_domain_name
      response = epp_plain_request(domain_create_xml({
        name: { value: dn }
      }), :xml)
      d = Domain.last
      response[:result_code].should == '1000'
      response[:msg].should == 'Command completed successfully'

      cre_data = response[:parsed].css('creData')

      cre_data.css('name').text.should == dn
      cre_data.css('crDate').text.should == d.created_at.to_time.utc.to_s
      cre_data.css('exDate').text.should == d.valid_to.to_time.utc.to_s

      response[:clTRID].should == 'ABC-12345'

      d.registrar.name.should == 'Registrar OÜ'
      d.tech_contacts.count.should == 2
      d.admin_contacts.count.should == 1

      d.nameservers.count.should == 2
      d.auth_info.should_not be_empty

      d.dnskeys.count.should == 1

      key = d.dnskeys.last

      key.ds_alg.should == 3
      key.ds_key_tag.should_not be_blank

      key.ds_digest_type.should == Setting.ds_algorithm
      key.flags.should == 257
      key.protocol.should == 3
      key.alg.should == 5
      key.public_key.should == 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8'
    end

    it 'creates a domain with legal document' do
      response = epp_plain_request(domain_create_xml_with_legal_doc, :xml)

      response[:msg].should == 'Command completed successfully'
      response[:result_code].should == '1000'
      d = Domain.last
      d.legal_documents.count.should == 1
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

      epp_plain_request(xml, :xml)
      d = Domain.last
      ds = d.dnskeys.last
      ds.ds_digest.should == '0B62D1BC64EFD1EE652FB102BDF1011BF514CCD9A1A0CFB7472AEA3B01F38C92'
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2306'
      response[:msg].should == 'IPv4 is missing'
    end

    it 'does not create duplicate domain' do
      dn = next_domain_name
      epp_plain_request(domain_create_xml({
        name: { value: dn }
      }), :xml)
      response = epp_plain_request(domain_create_xml({
        name: { value: dn }
      }), :xml)

      response[:result_code].should == '2302'
      response[:msg].should == 'Domain name already exists'
      response[:clTRID].should == 'ABC-12345'
    end

    it 'does not create reserved domain' do
      xml = domain_create_xml(name: { value: '1162.ee' })

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2302'
      response[:msg].should == 'Domain name is reserved or restricted'
      response[:clTRID].should == 'ABC-12345'
    end

    it 'does not create domain without contacts and registrant' do
      xml = domain_create_xml(contacts: [], registrant: false)

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '2003'
      response[:results][0][:msg].should == 'Required parameter missing: create > create > registrant'
    end

    it 'does not create domain without nameservers' do
      xml = domain_create_xml(ns: [])
      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2003'
      response[:msg].should == 'Required parameter missing: create > create > ns > hostAttr'
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2004'
      response[:msg].should == 'Nameservers count must be between 2-11'
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2005'
      response[:msg].should == 'Hostname is invalid'
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2003'
      response[:msg].should == 'Required parameter missing: create > create > ns > hostAttr'
    end

    it 'creates domain with nameservers with ips' do
      epp_plain_request(domain_create_with_host_attrs, :xml)
      Domain.last.nameservers.count.should == 2
      ns = Domain.last.nameservers.first
      ns.ipv4.should == '192.0.2.2'
      ns.ipv6.should == '1080:0:0:0:8:800:200C:417A'
    end

    it 'returns error when nameserver has invalid ips' do
      domain_count = Domain.count
      nameserver_count = Nameserver.count
      response = epp_plain_request(domain_create_with_invalid_ns_ip_xml, :xml)
      response[:results][0][:result_code].should == '2005'
      response[:results][0][:msg].should == 'IPv4 is invalid'
      response[:results][0][:value].should == '192.0.2.2.invalid'
      response[:results][1][:result_code].should == '2005'
      response[:results][1][:msg].should == 'IPv6 is invalid'
      response[:results][1][:value].should == 'INVALID_IPV6'
      # ensure nothing gets saved to db:
      Domain.count.should == domain_count
      Nameserver.count.should == nameserver_count
    end

    it 'creates a domain with period in days' do
      xml = domain_create_xml(period_value: 365, period_unit: 'd')

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '1000'
      response[:msg].should == 'Command completed successfully'
      Domain.first.valid_to.should == Date.today + 1.year
    end

    it 'does not create a domain with invalid period' do
      xml = domain_create_xml({
        period: { value: '367', attrs: { unit: 'd' } }
      })

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '2004'
      response[:results][0][:msg].should == 'Period must add up to 1, 2 or 3 years'
      response[:results][0][:value].should == '367'
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

      epp_plain_request(xml, :xml)
      d = Domain.last

      d.dnskeys.count.should == 3

      key_1 = d.dnskeys[0]
      key_1.ds_key_tag.should_not be_blank
      key_1.ds_alg.should == 3
      key_1.ds_digest_type.should == Setting.ds_algorithm

      d.dnskeys.pluck(:flags).should match_array([257, 0, 256])
      d.dnskeys.pluck(:protocol).should match_array([3, 3, 3])
      d.dnskeys.pluck(:alg).should match_array([3, 5, 254])
      d.dnskeys.pluck(:public_key).should match_array(%w(
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

      response = epp_plain_request(xml, :xml)

      response[:results][0][:msg].should == 'Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255'
      response[:results][0][:value].should == '9'

      response[:results][1][:msg].should == 'Valid protocols are: 3'
      response[:results][1][:value].should == '4'

      response[:results][2][:msg].should == 'Valid flags are: 0, 256, 257'
      response[:results][2][:value].should == '250'

      response[:results][3][:msg].should == 'Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255'
      response[:results][3][:value].should == '10'

      response[:results][4][:msg].should == 'Valid flags are: 0, 256, 257'
      response[:results][4][:value].should == '1'

      response[:results][5][:msg].should == 'Public key is missing'

      response[:results][6][:msg].should == 'Valid protocols are: 3'
      response[:results][6][:value].should == '5'
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

      response = epp_plain_request(xml, :xml)

      response[:result_code].should == '2302'
      response[:msg].should == 'Public key already exists'
      response[:results][0][:value].should == '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'
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

      response = epp_plain_request(xml, :xml)

      response[:result_code].should == '2004'
      response[:msg].should == 'DNS keys count must be between 0-1'

      create_settings
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

      epp_plain_request(xml, :xml)

      d = Domain.last
      ds = d.dnskeys.first
      ds.ds_key_tag.should == '12345'
      ds.ds_alg.should == 3
      ds.ds_digest_type.should == 1
      ds.ds_digest.should == '49FD46E6C4B45C55D4AC'
      ds.flags.should be_nil
      ds.protocol.should be_nil
      ds.alg.should be_nil
      ds.public_key.should be_nil
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

      epp_plain_request(xml, :xml)

      d = Domain.last
      ds = d.dnskeys.first
      ds.ds_key_tag.should == '12345'
      ds.ds_alg.should == 3
      ds.ds_digest_type.should == 1
      ds.ds_digest.should == '49FD46E6C4B45C55D4AC'
      ds.flags.should == 0
      ds.protocol.should == 3
      ds.alg.should == 5
      ds.public_key.should == '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2306'
      response[:msg].should == 'dsData object with key data is not allowed'

      create_settings
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2306'
      response[:msg].should == 'dsData object is not allowed'

      create_settings
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2306'
      response[:msg].should == 'keyData object is not allowed'

      create_settings
    end

    it 'prohibits dsData and keyData when they exists together' do
      xml = domain_create_xml({}, {
        _anonymus: [
          {
            dsData: {
              keyTag: { value: '12345' },
              alg: { value: '3' },
              digestType: { value: '1' },
              digest: { value: '49FD46E6C4B45C55D4AC' }
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

      response = epp_plain_request(xml, :xml)
      response[:msg].should == 'Mutually exclusive parameters: extension > create > keyData, '\
      'extension > create > dsData'
      response[:result_code].should == '2306'
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '1000'
      response[:msg].should == 'Command completed successfully'
      response[:clTRID].should == 'ABC-12345'

      Domain.last.tech_contacts.count.should == 1
      Domain.last.admin_contacts.count.should == 1

      tech_contact = Domain.last.tech_contacts.first
      tech_contact.code.should == 'juridical_1234'
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

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2004'
      response[:msg].should == 'Admin contacts count must be between 1-10'
      response[:clTRID].should == 'ABC-12345'

      Domain.count.should == domain_count
      DomainContact.count.should == domain_contact_count
    end

    it 'cannot assign juridical person as admin contact' do
      xml = domain_create_xml({
        registrant: { value: 'juridical_1234' },
        _anonymus: [
          { contact: { value: 'juridical_1234', attrs: { type: 'admin' } } }
        ]
      })

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2306'
      response[:msg].should == 'Admin contact can be only citizen'
    end
  end

  context 'with valid domain' do
    before(:each) { Fabricate(:domain, name: next_domain_name, registrar: registrar1, dnskeys: []) }
    let(:domain) { Domain.last }

    ### TRANSFER ###
    it 'transfers a domain' do
      domain.registrar = registrar1
      domain.save

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      response = login_as :registrar2 do
        epp_plain_request(xml, :xml)
      end

      domain.reload
      dtl = domain.domain_transfers.last

      trn_data = response[:parsed].css('trnData')
      trn_data.css('name').text.should == domain.name
      trn_data.css('trStatus').text.should == 'serverApproved'
      trn_data.css('reID').text.should == '123'
      trn_data.css('reDate').text.should == dtl.transfer_requested_at.to_time.utc.to_s
      trn_data.css('acID').text.should == '12345678'
      trn_data.css('acDate').text.should == dtl.transferred_at.to_time.utc.to_s
      trn_data.css('exDate').text.should == domain.valid_to.to_time.utc.to_s

      domain.registrar.should == registrar2

      Setting.transfer_wait_time = 1

      domain.reload
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }) # request with new password

      response = epp_plain_request(xml, :xml)
      trn_data = response[:parsed].css('trnData')

      domain.reload
      dtl = domain.domain_transfers.last

      domain.domain_transfers.count.should == 2

      trn_data.css('name').text.should == domain.name
      trn_data.css('trStatus').text.should == 'pending'
      trn_data.css('reID').text.should == '12345678'
      trn_data.css('reDate').text.should == dtl.transfer_requested_at.to_time.utc.to_s
      trn_data.css('acDate').text.should == dtl.wait_until.to_time.utc.to_s
      trn_data.css('acID').text.should == '123'
      trn_data.css('exDate').text.should == domain.valid_to.to_time.utc.to_s

      domain.registrar.should == registrar2

      # should return same data if pending already
      response = epp_plain_request(xml, :xml)
      trn_data = response[:parsed].css('trnData')

      domain.domain_transfers.count.should == 2
      trn_data.css('name').text.should == domain.name
      trn_data.css('trStatus').text.should == 'pending'
      trn_data.css('reID').text.should == '12345678'
      trn_data.css('reDate').text.should == dtl.transfer_requested_at.to_time.utc.to_s
      trn_data.css('acDate').text.should == dtl.wait_until.to_time.utc.to_s
      trn_data.css('acID').text.should == '123'
      trn_data.css('exDate').text.should == domain.valid_to.to_time.utc.to_s

      domain.registrar.should == registrar2

      # should show up in other registrar's poll

      response = login_as :registrar2 do
        epp_plain_request(epp_xml.session.poll, :xml)
      end

      response[:msg].should == 'Command completed successfully; ack to dequeue'
      msg_q = response[:parsed].css('msgQ')
      msg_q.css('qDate').text.should_not be_blank
      msg_q.css('msg').text.should == 'Transfer requested.'
      msg_q.first['id'].should_not be_blank
      msg_q.first['count'].should == '1'

      xml = epp_xml.session.poll(poll: {
        value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
      })

      response = login_as :registrar2 do
        epp_plain_request(xml, :xml)
      end

      response[:msg].should == 'Command completed successfully'
      msg_q = response[:parsed].css('msgQ')
      msg_q.first['id'].should_not be_blank
      msg_q.first['count'].should == '0'

      create_settings
    end

    it 'creates a domain transfer with legal document' do
      Setting.transfer_wait_time = 1
      domain.legal_documents.count.should == 0
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

      login_as :registrar2 do
        response = epp_plain_request(xml, :xml)
        response[:result_code].should == '1000'
        domain.legal_documents.count.should == 1

        log = ApiLog::EppLog.last

        log.request_command.should == 'transfer'
        log.request_object.should == 'domain'
        log.request_successful.should == true
        log.api_user_name.should == 'registrar2'
        log.api_user_registrar.should == 'registrar2'
        log.request.should_not be_blank
        log.response.should_not be_blank
      end

      response = login_as :registrar2 do
        epp_plain_request(xml, :xml)
      end

      response[:result_code].should == '1000'
      domain.legal_documents.count.should == 1 # does not add another legal documen

      create_settings
    end

    it 'approves the transfer request' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: registrar2,
        transfer_from: registrar1
      })

      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: domain.auth_info } }
      }, 'approve')

      response = epp_plain_request(xml, :xml)

      domain.reload
      dtl = domain.domain_transfers.last

      trn_data = response[:parsed].css('trnData')

      trn_data.css('name').text.should == domain.name
      trn_data.css('trStatus').text.should == 'clientApproved'
      trn_data.css('reID').text.should == '123'
      trn_data.css('reDate').text.should == dtl.transfer_requested_at.to_time.utc.to_s
      trn_data.css('acID').text.should == '12345678'
      trn_data.css('exDate').text.should == domain.valid_to.to_time.utc.to_s
    end

    it 'rejects a domain transfer' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: registrar2,
        transfer_from: registrar1
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

      response = login_as :registrar2 do
        epp_plain_request(xml, :xml)
      end

      response[:msg].should == 'Transfer can be rejected only by current registrar'
      response[:result_code].should == '2304'
      domain.legal_documents.count.should == 0

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '1000'
      domain.pending_transfer.should be_nil
      domain.legal_documents.count.should == 1
    end

    it 'prohibits wrong registrar from approving transfer' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: registrar2,
        transfer_from: registrar1
      })

      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: domain.auth_info } }
      }, 'approve')

      response = login_as :registrar2 do
        epp_plain_request(xml, :xml)
      end

      response[:result_code].should == '2304'
      response[:msg].should == 'Transfer can be approved only by current domain registrar'
    end

    it 'does not transfer with invalid pw' do
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: 'test' } }
      })
      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '2201'
      response[:msg].should == 'Authorization error'
    end

    it 'ignores transfer when owner registrar requests transfer' do
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      response = epp_plain_request(xml, :xml)

      response[:result_code].should == '2002'
      response[:msg].should == 'Domain already belongs to the querying registrar'
    end

    it 'returns an error for incorrect op attribute' do
      response = epp_plain_request(domain_transfer_xml({}, 'bla'), :xml)
      response[:result_code].should == '2306'
      response[:msg].should == 'Attribute is invalid: op'
    end

    it 'creates new pw after successful transfer' do
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        epp_plain_request(xml, :xml) # transfer domain
        response =  epp_plain_request(xml, :xml) # attempt second transfer
        response[:result_code].should == '2201'
        response[:msg].should == 'Authorization error'
      end
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

      response = epp_plain_request(domain_update_xml(xml_params, {}, {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          }
        ]
      }), :xml)

      response[:results][0][:result_code].should == '1000'

      d = Domain.last

      d.owner_contact_code.should == 'citizen_1234'
      d.auth_info.should == existing_pw
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

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Contact was not found'

      Fabricate(:contact, code: 'mak21')

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '1000'

      d = Domain.last

      new_ns_count = d.nameservers.where(hostname: ['ns1.example.com', 'ns2.example.com']).count
      new_ns_count.should == 2

      new_contact = d.tech_contacts.find_by(code: 'mak21')
      new_contact.should be_truthy

      d.domain_statuses.count.should == 2
      d.domain_statuses.first.description.should == 'Payment overdue.'
      d.domain_statuses.first.value.should == 'clientHold'

      d.domain_statuses.last.value.should == 'clientUpdateProhibited'
      d.dnskeys.count.should == 2

      response = epp_plain_request(xml, :xml)

      response[:results][0][:result_code].should == '2302'
      response[:results][0][:msg].should == 'Nameserver already exists on this domain'
      response[:results][0][:value].should == 'ns1.example.com'

      response[:results][1][:result_code].should == '2302'
      response[:results][1][:msg].should == 'Nameserver already exists on this domain'
      response[:results][1][:value].should == 'ns2.example.com'

      response[:results][2][:result_code].should == '2302'
      response[:results][2][:msg].should == 'Contact already exists on this domain'
      response[:results][2][:value].should == 'mak21'

      response[:results][3][:msg].should == 'Status already exists on this domain'
      response[:results][3][:value].should == 'clientHold'

      response[:results][4][:msg].should == 'Status already exists on this domain'
      response[:results][4][:value].should == 'clientUpdateProhibited'

      response[:results][5][:msg].should == 'Public key already exists'
      response[:results][5][:value].should == '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'

      response[:results][6][:msg].should == 'Public key already exists'
      response[:results][6][:value].should == '841936717ae427ace63c28d04918569a841936717ae427ace63c28d0'

      d.domain_statuses.count.should == 2
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

      epp_plain_request(xml, :xml)
      d = Domain.last
      d.dnskeys.count.should == 2

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

      epp_plain_request(xml, :xml)

      d.dnskeys.count.should == 1

      d.domain_statuses.count.should == 1
      d.domain_statuses.first.value.should == 'clientUpdateProhibited'

      rem_ns = d.nameservers.find_by(hostname: 'ns1.example.com')
      rem_ns.should be_falsey

      rem_cnt = d.tech_contacts.find_by(code: 'citizen_1234')
      rem_cnt.should be_falsey

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Contact was not found'
      response[:results][0][:value].should == 'citizen_1234'

      response[:results][1][:result_code].should == '2303'
      response[:results][1][:msg].should == 'Nameserver was not found'
      response[:results][1][:value].should == 'ns1.example.com'

      response[:results][2][:result_code].should == '2303'
      response[:results][2][:msg].should == 'Status was not found'
      response[:results][2][:value].should == 'clientHold'
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

      response = epp_plain_request(xml, :xml)

      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Status was not found'
      response[:results][0][:value].should == 'serverHold'
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

      epp_plain_request(xml, :xml)
      response = epp_plain_request(xml, :xml)

      response[:results][0][:result_code].should == '2302'
      response[:results][0][:msg].should == 'Nameserver already exists on this domain'
      response[:results][0][:value].should == n.hostname

      response[:results][1][:result_code].should == '2302'
      response[:results][1][:msg].should == 'Contact already exists on this domain'
      response[:results][1][:value].should == c.code
    end

    it 'cannot change registrant without legal document' do
      xml_params = {
        name: { value: domain.name },
        chg: [
          registrant: { value: 'citizen_1234' }
        ]
      }

      response = epp_plain_request(domain_update_xml(xml_params), :xml)
      response[:results][0][:msg].should == 'Required parameter missing: extension > extdata > legalDocument'
      response[:results][0][:result_code].should == '2003'
    end

    it 'does not assign invalid status to domain' do
      xml = domain_update_xml({
        name: { value: domain.name },
        add: [
          status: { value: '', attrs: { s: 'invalidStatus' } }
        ]
      })

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Status was not found'
      response[:results][0][:value].should == 'invalidStatus'
    end

    ### RENEW ###
    it 'renews a domain' do
      exp_date = (Date.today + 1.year)
      xml = epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml, :xml)
      ex_date = response[:parsed].css('renData exDate').text
      name = response[:parsed].css('renData name').text
      ex_date.should == "#{(exp_date + 1.year)} 00:00:00 UTC"
      name.should == domain.name
    end

    it 'returns an error when given and current exp dates do not match' do
      xml = epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: '2200-08-07' },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '2306'
      response[:results][0][:msg].should == 'Given and current expire dates do not match'
    end

    it 'returns an error when period is invalid' do
      exp_date = (Date.today + 1.year)

      xml = epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '4', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '2004'
      response[:results][0][:msg].should == 'Period must add up to 1, 2 or 3 years'
      response[:results][0][:value].should == '4'
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

      response = epp_plain_request(xml, :xml)
      response[:results][0][:result_code].should == '1000'
      response[:results][0][:msg].should == 'Command completed successfully'

      inf_data = response[:parsed].css('resData infData')
      inf_data.css('name').text.should == domain.name
      inf_data.css('status').text.should == 'Payment overdue.'
      inf_data.css('status').first[:s].should == 'clientHold'
      inf_data.css('registrant').text.should == domain.owner_contact_code

      admin_contacts_from_request = inf_data.css('contact[type="admin"]').map(&:text)
      admin_contacts_existing = domain.admin_contacts.pluck(:code)

      admin_contacts_from_request.should == admin_contacts_existing

      hosts_from_request = inf_data.css('hostName').map(&:text)
      hosts_existing = domain.nameservers.pluck(:hostname)

      hosts_from_request.should == hosts_existing

      ns1 = inf_data.css('hostAttr').last

      ns1.css('hostName').last.text.should == 'ns1.example.com'
      ns1.css('hostAddr').first.text.should == '192.168.1.1'
      ns1.css('hostAddr').last.text.should == '1080:0:0:0:8:800:200C:417A'
      inf_data.css('crDate').text.should == domain.created_at.to_time.utc.to_s
      inf_data.css('exDate').text.should == domain.valid_to.to_time.utc.to_s
      inf_data.css('pw').text.should == domain.auth_info

      ds_data_1 = response[:parsed].css('dsData')[0]

      ds_data_1.css('keyTag').first.text.should == '123'
      ds_data_1.css('alg').first.text.should == '3'
      ds_data_1.css('digestType').first.text.should == '1'
      ds_data_1.css('digest').first.text.should == 'abc'

      dnskey_1 = ds_data_1.css('keyData')[0]
      dnskey_1.css('flags').first.text.should == '257'
      dnskey_1.css('protocol').first.text.should == '3'
      dnskey_1.css('alg').first.text.should == '3'
      dnskey_1.css('pubKey').first.text.should == 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8'

      ds_data_2 = response[:parsed].css('dsData')[1]

      dnskey_2 = ds_data_2.css('keyData')[0]
      dnskey_2.css('flags').first.text.should == '0'
      dnskey_2.css('protocol').first.text.should == '3'
      dnskey_2.css('alg').first.text.should == '5'
      dnskey_2.css('pubKey').first.text.should == '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'

      domain.touch

      response = epp_plain_request(domain_info_xml(name: { value: domain.name }), :xml)
      inf_data = response[:parsed].css('resData infData')

      inf_data.css('upDate').text.should == domain.updated_at.to_time.utc.to_s
    end

    it 'returns error when domain can not be found' do
      response = epp_plain_request(domain_info_xml(name:  { value: 'test.ee' }), :xml)
      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Domain not found'
    end

    it 'sets ok status by default' do
      response = epp_plain_request(domain_info_xml(name: { value: domain.name }), :xml)
      inf_data = response[:parsed].css('resData infData')
      inf_data.css('status').first[:s].should == 'ok'
    end

    it 'can not see other registrar domains' do
      login_as :registrar2 do
        response = epp_plain_request(domain_info_xml(name: { value: domain.name }), :xml)
        response[:result_code].should == '2302'
        response[:msg].should == 'Domain exists but belongs to other registrar'
      end
    end

    it 'validates legal document type' do
      xml = epp_xml.domain.info({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'jpg' }
          }
        ]
      })

      response = epp_plain_request(xml, :xml)
      response[:msg].should == 'Attribute is invalid: type'

      xml = epp_xml.domain.info({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp=='
          }
        ]
      })

      response = epp_plain_request(xml, :xml)
      response[:msg].should == 'Attribute is invalid: type'
    end

    ### DELETE ###
    it 'deletes domain' do
      response = epp_plain_request(epp_xml.domain.delete({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          }
        ]
      }), :xml)

      response[:result_code].should == '1000'

      Domain.find_by(name: domain.name).should == nil
    end

    it 'does not delete domain with specific status' do
      domain.domain_statuses.create(value: DomainStatus::CLIENT_DELETE_PROHIBITED)

      response = epp_plain_request(epp_xml.domain.delete({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          }
        ]
      }), :xml)

      response[:result_code].should == '2304'
      response[:msg].should == 'Domain status prohibits operation'
    end

    it 'does not delete domain without legal document' do
      response = epp_plain_request(epp_xml.domain.delete(name: { value: 'example.ee' }), :xml)
      response[:result_code].should == '2003'
      response[:msg].should == 'Required parameter missing: extension > extdata > legalDocument'
    end

    ### CHECK ###
    it 'checks a domain' do
      response = epp_plain_request(domain_check_xml({
        _anonymus: [
          { name: { value: 'one.ee' } }
        ]
      }), :xml)

      response[:result_code].should == '1000'
      response[:msg].should == 'Command completed successfully'

      res_data = response[:parsed].css('resData chkData cd name').first
      res_data.text.should == 'one.ee'
      res_data[:avail].should == '1'

      response = epp_plain_request(domain_check_xml({
        _anonymus: [
          { name: { value: domain.name } }
        ]
      }), :xml)
      res_data = response[:parsed].css('resData chkData cd').first
      name = res_data.css('name').first
      reason = res_data.css('reason').first

      name.text.should == domain.name
      name[:avail].should == '0'
      reason.text.should == 'in use'
    end

    it 'checks multiple domains' do
      xml = domain_check_xml({
        _anonymus: [
          { name: { value: 'one.ee' } },
          { name: { value: 'two.ee' } },
          { name: { value: 'three.ee' } }
        ]
      })

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '1000'
      response[:msg].should == 'Command completed successfully'

      res_data = response[:parsed].css('resData chkData cd name').first
      res_data.text.should == 'one.ee'
      res_data[:avail].should == '1'

      res_data = response[:parsed].css('resData chkData cd name').last
      res_data.text.should == 'three.ee'
      res_data[:avail].should == '1'
    end

    it 'checks invalid format domain' do
      xml = domain_check_xml({
        _anonymus: [
          { name: { value: 'one.ee' } },
          { name: { value: 'notcorrectdomain' } }
        ]
      })

      response = epp_plain_request(xml, :xml)
      response[:result_code].should == '1000'
      response[:msg].should == 'Command completed successfully'

      res_data = response[:parsed].css('resData chkData cd name').first
      res_data.text.should == 'one.ee'
      res_data[:avail].should == '1'

      res_data = response[:parsed].css('resData chkData cd').last
      name = res_data.css('name').first
      reason = res_data.css('reason').first

      name.text.should == 'notcorrectdomain'
      name[:avail].should == '0'
      reason.text.should == 'invalid format'
    end
  end

end
