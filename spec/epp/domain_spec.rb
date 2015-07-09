require 'rails_helper'

describe 'EPP Domain', epp: true do
  before(:all) do
    @xsd = Nokogiri::XML::Schema(File.read('doc/schemas/domain-eis-1.0.xsd'))
    @epp_xml = EppXml.new(cl_trid: 'ABC-12345')
    @registrar1 = Fabricate(:registrar1, code: 'REGDOMAIN1')
    @registrar1.credit!(10000, '')
    @registrar2 = Fabricate(:registrar2, code: 'REGDOMAIN2')
    @registrar2.credit!(10000, '')
    Fabricate(:api_user, username: 'registrar1', registrar: @registrar1)
    Fabricate(:api_user, username: 'registrar2', registrar: @registrar2)

    login_as :registrar1

    Fabricate(:contact, code: 'FIXED:CITIZEN_1234')
    Fabricate(:contact, code: 'FIXED:SH8013')
    Fabricate(:contact, code: 'FIXED:SH801333')
    Fabricate(:contact, code: 'FIXED:JURIDICAL_1234', ident_type: 'bic')
    Fabricate(:reserved_domain)
    Fabricate(:blocked_domain)
    Fabricate(:pricelist, valid_to: nil)
    Fabricate(:pricelist, duration: '2years', price: 20, valid_to: nil)
    Fabricate(:pricelist, duration: '3years', price: 30, valid_to: nil)
    Fabricate(:pricelist, operation_category: 'renew', price: 15, valid_to: nil)
    Fabricate(:pricelist, operation_category: 'renew', duration: '2years', price: 35, valid_to: nil)
    Fabricate(:pricelist, operation_category: 'renew', duration: '3years', price: 62, valid_to: nil)

    @uniq_no = proc { @i ||= 0; @i += 1 }
  end

  it 'should return error if balance low' do
    f = Fabricate(:pricelist, valid_to: Time.zone.now + 1.day, price: 100000)

    dn = next_domain_name
    response = epp_plain_request(domain_create_xml({
      name: { value: dn }
    }))

    response[:msg].should == "Billing failure - credit balance low"
    response[:result_code].should == '2104'
    f.delete
  end

  it 'returns error if contact does not exists' do
    response = epp_plain_request(domain_create_xml({
      registrant: { value: 'FIXED:CITIZEN_1234' },
      _anonymus: [
        { contact: { value: 'FIXED:CITIZEN_1234', attrs: { type: 'admin' } } },
        { contact: { value: 'sh1111', attrs: { type: 'tech' } } },
        { contact: { value: 'sh2222', attrs: { type: 'tech' } } }
      ]
    }))

    response[:results][0][:msg].should == 'Contact was not found'
    response[:results][0][:result_code].should == '2303'
    response[:results][0][:value].should == 'sh1111'

    response[:results][1][:msg].should == 'Contact was not found'
    response[:results][1][:result_code].should == '2303'
    response[:results][1][:value].should == 'sh2222'

    response[:clTRID].should == 'ABC-12345'

    log = ApiLog::EppLog.last

    log.request_command.should == 'create'
    log.request_object.should == 'domain'
    log.request_successful.should == false
    log.api_user_name.should == '1-api-registrar1'
    log.api_user_registrar.should == 'registrar1'
    log.request.should_not be_blank
    log.response.should_not be_blank
  end

  it 'validates required parameters' do
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    xml = epp_xml.create({
      name: { value: 'test.ee' }
    })

    response = epp_plain_request(xml)
    response[:results][0][:result_code].should == '2003'
    response[:results][0][:msg].should ==
      'Required parameter missing: create > create > ns [ns]'

    response[:results][1][:result_code].should == '2003'
    response[:results][1][:msg].should ==
      'Required parameter missing: create > create > registrant [registrant]'

    response[:results][2][:result_code].should == '2003'
    response[:results][2][:msg].should ==
      'Required parameter missing: create > create > ns > hostAttr [host_attr]'

    response[:results][3][:result_code].should == '2003'
    response[:results][3][:msg].should ==
      'Required parameter missing: extension > extdata > legalDocument [legal_document]'
  end

  context 'with citizen as a registrant' do
    it 'creates a domain' do
      dn = next_domain_name
      response = epp_plain_request(domain_create_xml({
        name: { value: dn }
      }))

      d = Domain.last
      response[:msg].should == 'Command completed successfully'
      response[:result_code].should == '1000'

      cre_data = response[:parsed].css('creData')

      cre_data.css('name').text.should == dn
      cre_data.css('crDate').text.should == d.created_at.in_time_zone.utc.utc.iso8601
      cre_data.css('exDate').text.should == d.valid_to.in_time_zone.utc.utc.iso8601

      response[:clTRID].should == 'ABC-12345'

      d.registrar.name.should == 'registrar1'
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
      response = epp_plain_request(domain_create_xml_with_legal_doc)

      response[:msg].should == 'Command completed successfully'
      response[:result_code].should == '1000'
      d = Domain.last
      d.legal_documents.count.should == 1
    end

    # it 'creates ria.ee with valid ds record' do
      # xml = domain_create_xml({
        # name: { value: 'ria.ee' }
      # }, {
        # _anonymus: [
          # { keyData: {
              # flags: { value: '257' },
              # protocol: { value: '3' },
              # alg: { value: '8' },
              # pubKey: { value: 'AwEAAaOf5+lz3ftsL+0CCvfJbhUF/NVsNh8BKo61oYs5fXVbuWDiH872 '\
                # 'LC8uKDO92TJy7Q4TF9XMAKMMlf1GMAxlRspD749SOCTN00sqfWx1OMTu '\
                # 'a28L1PerwHq7665oDJDKqR71btcGqyLKhe2QDvCdA0mENimF1NudX1BJ '\
                # 'DDFi6oOZ0xE/0CuveB64I3ree7nCrwLwNs56kXC4LYoX3XdkOMKiJLL/ '\
                # 'MAhcxXa60CdZLoRtTEW3z8/oBq4hEAYMCNclpbd6y/exScwBxFTdUfFk '\
                # 'KsdNcmvai1lyk9vna0WQrtpYpHKMXvY9LFHaJxCOLR4umfeQ42RuTd82 lqfU6ClMeXs=' }
            # }
          # }
        # ]
      # })

      # epp_plain_request(xml)

      # d = Domain.last
      # ds = d.dnskeys.last
      # ds.ds_digest.should == '0B62D1BC64EFD1EE652FB102BDF1011BF514CCD9A1A0CFB7472AEA3B01F38C92'
    # end

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

      response = epp_plain_request(xml)

      response[:result_code].should == '2306'
      response[:msg].should == 'IPv4 is missing [ipv4]'
    end

    # it 'does not create duplicate domain' do
      # dn = next_domain_name
      # epp_plain_request(domain_create_xml({
        # name: { value: dn }
      # }))
      # response = epp_plain_request(domain_create_xml({
        # name: { value: dn }
      # }))

      # response[:msg].should == 'Domain name already exists'
      # response[:result_code].should == '2302'
      # response[:clTRID].should == 'ABC-12345'
    # end

    it 'does not create domain longer than 63 punicode characters' do
      xml = domain_create_xml(name: { value: "#{'ä' * 63}.ee" })

      response = epp_plain_request(xml)
      response[:msg].should == 'Domain name is too long (maximum is 63 characters) [puny_label]'
      response[:result_code].should == '2005'
      response[:clTRID].should == 'ABC-12345'
    end

    it 'does not create reserved domain' do
      xml = domain_create_xml(name: { value: '1162.ee' })

      response = epp_plain_request(xml)
      response[:result_code].should == '2304'
      response[:msg].should == 'Domain is reserved and requires correct auth info'
      response[:clTRID].should == 'ABC-12345'

      xml = domain_create_xml(name: { value: '1162.ee' }, authInfo: { pw: { value: 'wrong_pw' } })
      response = epp_plain_request(xml)
      response[:result_code].should == '2304'
      response[:msg].should == 'Domain is reserved and requires correct auth info'
    end

    it 'creates a reserved domain with correct auth info' do
      xml = domain_create_xml(name: { value: '1162.ee' }, authInfo: { pw: { value: 'abc' } })

      response = epp_plain_request(xml)
      response[:msg].should == 'Command completed successfully'
      response[:result_code].should == '1000'

      d = Domain.last
      d.statuses.should match_array(['ok'])
      d.auth_info.should_not == 'abc' # should generate entirely new auth info after domain create
    end

    it 'does not create blocked domain' do
      xml = domain_create_xml(name: { value: 'ftp.ee' })

      response = epp_plain_request(xml)
      response[:result_code].should == '2302'
      response[:msg].should == 'Domain name is blocked [name_dirty]'
      response[:clTRID].should == 'ABC-12345'
    end

    it 'does not create domain without contacts and registrant' do
      xml = domain_create_xml(_anonymus: [], registrant: false)

      response = epp_plain_request(xml)
      response[:results][0][:result_code].should == '2003'
      response[:results][0][:msg].should ==
        'Required parameter missing: create > create > registrant [registrant]'
    end

    it 'does not create domain without nameservers' do
      xml = domain_create_xml(ns: nil)
      response = epp_plain_request(xml)

      response[:results][0][:msg].should ==
        'Required parameter missing: create > create > ns [ns]'
      response[:results][0][:result_code].should == '2003'

      response[:results][1][:msg].should ==
        'Required parameter missing: create > create > ns > hostAttr [host_attr]'
      response[:results][1][:result_code].should == '2003'

      response[:results].count.should == 2
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

      response = epp_plain_request(xml)
      response[:result_code].should == '2004'
      response[:msg].should == 'Nameservers count must be between 2-11 [nameservers]'
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

      response = epp_plain_request(xml)
      response[:msg].should == 'Hostname is invalid [hostname]'
      response[:result_code].should == '2005'
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

      response = epp_plain_request(xml)
      response[:msg].should == 'Required parameter missing: create > create > ns > hostAttr [host_attr]'
      response[:result_code].should == '2003'
    end

    it 'creates domain with nameservers with ips' do
      epp_plain_request(domain_create_with_host_attrs)
      Domain.last.nameservers.count.should == 2
      ns = Domain.last.nameservers.first
      ns.ipv4.should == '192.0.2.2'
      ns.ipv6.should == '1080:0:0:0:8:800:200C:417A'
    end

    it 'returns error when nameserver has invalid ips' do
      domain_count = Domain.count
      nameserver_count = Nameserver.count
      response = epp_plain_request(domain_create_with_invalid_ns_ip_xml)
      response[:results][0][:result_code].should == '2005'
      response[:results][0][:msg].should == 'IPv4 is invalid [ipv4]'
      response[:results][0][:value].should == '192.0.2.2.invalid'
      response[:results][1][:result_code].should == '2005'
      response[:results][1][:msg].should == 'IPv6 is invalid [ipv6]'
      response[:results][1][:value].should == 'INVALID_IPV6'
      # ensure nothing gets saved to db:
      Domain.count.should == domain_count
      Nameserver.count.should == nameserver_count
    end

    it 'creates a domain with period in days' do
      old_balance = @registrar1.balance
      old_activities = @registrar1.cash_account.account_activities.count
      xml = domain_create_xml(period: { value: '365', attrs: { unit: 'd' } })

      response = epp_plain_request(xml)
      response[:msg].should == 'Command completed successfully'
      response[:result_code].should == '1000'
      Domain.last.valid_to.should be_within(60).of(1.year.since)
      @registrar1.balance.should be < old_balance
      @registrar1.cash_account.account_activities.count.should == old_activities + 1
      a = @registrar1.cash_account.account_activities.last
      a.description.should == "Create #{Domain.last.name}"
      a.sum.should == -BigDecimal.new('10.0')
      a.activity_type = AccountActivity::CREATE
    end

    it 'creates a domain with longer periods' do
      old_balance = @registrar1.balance
      old_activities = @registrar1.cash_account.account_activities.count
      xml = domain_create_xml(period: { value: '2', attrs: { unit: 'y' } })

      response = epp_plain_request(xml)
      response[:msg].should == 'Command completed successfully'
      response[:result_code].should == '1000'
      Domain.last.valid_to.should be_within(60).of(2.years.since)
      @registrar1.balance.should be < old_balance
      @registrar1.cash_account.account_activities.count.should == old_activities + 1
      a = @registrar1.cash_account.account_activities.last
      a.description.should == "Create #{Domain.last.name}"
      a.sum.should == -BigDecimal.new('20.0')
      a.activity_type = AccountActivity::CREATE
    end

    it 'creates a domain with longer periods' do
      old_balance = @registrar1.balance
      old_activities = @registrar1.cash_account.account_activities.count
      xml = domain_create_xml(period: { value: '36', attrs: { unit: 'm' } })

      response = epp_plain_request(xml)
      response[:msg].should == 'Command completed successfully'
      response[:result_code].should == '1000'
      Domain.last.valid_to.should be_within(60).of(3.years.since)
      @registrar1.balance.should be < old_balance
      @registrar1.cash_account.account_activities.count.should == old_activities + 1
      a = @registrar1.cash_account.account_activities.last
      a.description.should == "Create #{Domain.last.name}"
      a.sum.should == -BigDecimal.new('30.0')
      a.activity_type = AccountActivity::CREATE
    end

    it 'does not create a domain with invalid period' do
      old_balance = @registrar1.balance
      old_activities = @registrar1.cash_account.account_activities.count
      xml = domain_create_xml({
        period: { value: '367', attrs: { unit: 'd' } }
      })

      response = epp_plain_request(xml)
      response[:results][0][:result_code].should == '2306'
      response[:results][0][:msg].should == 'Period must add up to 1, 2 or 3 years [period]'
      response[:results][0][:value].should == '367'
      @registrar1.balance.should == old_balance
      @registrar1.cash_account.account_activities.count.should == old_activities
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

      epp_plain_request(xml)
      d = Domain.last

      d.dnskeys.count.should == 3

      ksk = d.dnskeys.find_by(flags: 257)
      ksk.ds_key_tag.should_not be_blank
      ksk.ds_alg.should == 3
      ksk.ds_digest_type.should == Setting.ds_algorithm

      zsk = d.dnskeys.find_by(flags: 256)
      zsk.ds_key_tag.should be_blank

      zero = d.dnskeys.find_by(flags: 0)
      zero.ds_key_tag.should be_blank

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

      response = epp_plain_request(xml, validate_input: false)

      response[:results][0][:msg].should ==
        'Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255 [alg]'
      response[:results][0][:value].should == '9'

      response[:results][1][:msg].should == 'Valid protocols are: 3 [protocol]'
      response[:results][1][:value].should == '4'

      response[:results][2][:msg].should == 'Valid flags are: 0, 256, 257 [flags]'
      response[:results][2][:value].should == '250'

      response[:results][3][:msg].should == 'Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255 [alg]'
      response[:results][3][:value].should == '10'

      response[:results][4][:msg].should == 'Valid flags are: 0, 256, 257 [flags]'
      response[:results][4][:value].should == '1'

      response[:results][5][:msg].should == 'Public key is missing [public_key]'

      response[:results][6][:msg].should == 'Valid protocols are: 3 [protocol]'
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

      response = epp_plain_request(xml)

      response[:result_code].should == '2302'
      response[:msg].should == 'Public key already exists [public_key]'
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

      response = epp_plain_request(xml)

      response[:result_code].should == '2004'
      response[:msg].should == 'DNS keys count must be between 0-1 [dnskeys]'

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

      epp_plain_request(xml)

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

      epp_plain_request(xml)

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

    # it 'prohibits dsData with key' do
    #   Setting.ds_data_with_key_allowed = false

    #   xml = domain_create_xml({}, {
    #     _anonymus: [
    #       { dsData: {
    #           keyTag: { value: '12345' },
    #           alg: { value: '3' },
    #           digestType: { value: '1' },
    #           digest: { value: '49FD46E6C4B45C55D4AC' },
    #           keyData: {
    #             flags: { value: '0' },
    #             protocol: { value: '3' },
    #             alg: { value: '5' },
    #             pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
    #           }
    #         }
    #       }]
    #     })

    #   response = epp_plain_request(xml)
    #   response[:result_code].should == '2306'
    #   response[:msg].should == 'dsData object with key data is not allowed'

    #   create_settings
    # end

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

      response = epp_plain_request(xml)
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

      response = epp_plain_request(xml)
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

      response = epp_plain_request(xml, validate_input: false)
      response[:msg].should == 'Mutually exclusive parameters: extension > create > keyData, '\
      'extension > create > dsData'
      response[:result_code].should == '2306'
    end
  end

  context 'with juridical persion as a registrant' do
    it 'creates a domain with contacts' do
      xml = domain_create_xml({
        registrant: { value: 'FIXED:JURIDICAL_1234' },
        _anonymus: [
          { contact: { value: 'FIXED:SH8013', attrs: { type: 'admin' } } }
        ]
      })

      response = epp_plain_request(xml)
      response[:msg].should == 'Command completed successfully'
      response[:result_code].should == '1000'
      response[:clTRID].should == 'ABC-12345'

      Domain.last.tech_contacts.count.should == 1
      Domain.last.admin_contacts.count.should == 1

      tech_contact = Domain.last.tech_contacts.first
      tech_contact.code.should == 'FIXED:JURIDICAL_1234'
    end

    it 'does not create a domain without admin contact' do
      domain_count = Domain.count
      domain_contact_count = DomainContact.count
      xml = domain_create_xml({
        registrant: { value: 'FIXED:JURIDICAL_1234' },
        _anonymus: [
          { contact: { value: 'FIXED:SH8013', attrs: { type: 'tech' } } }
        ]
      })

      response = epp_plain_request(xml)
      response[:msg].should == 'Admin contacts count must be between 1-10 [admin_domain_contacts]'
      response[:result_code].should == '2004'
      response[:clTRID].should == 'ABC-12345'

      Domain.count.should == domain_count
      DomainContact.count.should == domain_contact_count
    end

    it 'cannot assign juridical person as admin contact' do
      xml = domain_create_xml({
        registrant: { value: 'FIXED:JURIDICAL_1234' },
        _anonymus: [
          { contact: { value: 'FIXED:JURIDICAL_1234', attrs: { type: 'admin' } } }
        ]
      })

      response = epp_plain_request(xml)
      response[:msg].should == 'Admin contact can be private person only'
      response[:result_code].should == '2306'
    end
  end

  context 'with valid domain' do
    let(:domain) { Fabricate(:domain, registrar: @registrar1, dnskeys: []) }

    ### TRANSFER ###
    it 'transfers a domain' do
      domain.registrar = @registrar1
      domain.save

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }, 'query', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      old_contact_codes = domain.contacts.pluck(:code).sort.uniq
      old_registrant_code = domain.registrant.code

      response = login_as :registrar2 do
        epp_plain_request(xml)
      end

      domain.reload
      dtl = domain.domain_transfers.last

      trn_data = response[:parsed].css('trnData')
      trn_data.css('name').text.should == domain.name
      trn_data.css('trStatus').text.should == 'serverApproved'
      trn_data.css('reID').text.should == 'REGDOMAIN2'
      trn_data.css('reDate').text.should == dtl.transfer_requested_at.in_time_zone.utc.utc.iso8601
      trn_data.css('acID').text.should == 'REGDOMAIN1'
      trn_data.css('acDate').text.should == dtl.transferred_at.in_time_zone.utc.utc.iso8601
      trn_data.css('exDate').text.should == domain.valid_to.in_time_zone.utc.utc.iso8601

      domain.registrar.should == @registrar2

      response = epp_plain_request(@epp_xml.session.poll)

      response[:msg].should == 'Command completed successfully; ack to dequeue'
      msg_q = response[:parsed].css('msgQ')
      msg_q.css('qDate').text.should_not be_blank

      msg_q.css('msg').text.should == "Domain transfer was approved, associated contacts were: " \
        "#{old_contact_codes} and registrant was #{old_registrant_code}"
      msg_q.first['id'].should_not be_blank
      msg_q.first['count'].should == '1'

      Setting.transfer_wait_time = 1

      domain.reload
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }, 'query', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }) # request with new password

      response = epp_plain_request(xml)
      trn_data = response[:parsed].css('trnData')

      domain.reload
      dtl = domain.domain_transfers.last

      domain.domain_transfers.count.should == 2

      trn_data.css('name').text.should == domain.name
      trn_data.css('trStatus').text.should == 'pending'
      trn_data.css('reID').text.should == 'REGDOMAIN1'
      trn_data.css('reDate').text.should == dtl.transfer_requested_at.in_time_zone.utc.utc.iso8601
      trn_data.css('acDate').text.should == dtl.wait_until.in_time_zone.utc.utc.iso8601
      trn_data.css('acID').text.should == 'REGDOMAIN2'
      trn_data.css('exDate').text.should == domain.valid_to.in_time_zone.utc.utc.iso8601

      domain.registrar.should == @registrar2

      # should return same data if pending already
      response = epp_plain_request(xml)
      trn_data = response[:parsed].css('trnData')

      domain.domain_transfers.count.should == 2
      trn_data.css('name').text.should == domain.name
      trn_data.css('trStatus').text.should == 'pending'
      trn_data.css('reID').text.should == 'REGDOMAIN1'
      trn_data.css('reDate').text.should == dtl.transfer_requested_at.in_time_zone.utc.utc.iso8601
      trn_data.css('acDate').text.should == dtl.wait_until.in_time_zone.utc.utc.iso8601
      trn_data.css('acID').text.should == 'REGDOMAIN2'
      trn_data.css('exDate').text.should == domain.valid_to.in_time_zone.utc.utc.iso8601

      domain.registrar.should == @registrar2

      # should show up in other registrar's poll

      response = login_as :registrar2 do
        epp_plain_request(@epp_xml.session.poll)
      end

      response[:msg].should == 'Command completed successfully; ack to dequeue'
      msg_q = response[:parsed].css('msgQ')
      msg_q.css('qDate').text.should_not be_blank
      msg_q.css('msg').text.should == 'Transfer requested.'
      msg_q.first['id'].should_not be_blank
      msg_q.first['count'].should == '1'

      xml = @epp_xml.session.poll(poll: {
        value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
      })

      response = login_as :registrar2 do
        epp_plain_request(xml)
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
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:result_code].should == '1000'
        domain.legal_documents.count.should == 1

        log = ApiLog::EppLog.last

        log.request_command.should == 'transfer'
        log.request_object.should == 'domain'
        log.request_successful.should == true
        log.api_user_name.should == '2-api-registrar2'
        log.api_user_registrar.should == 'registrar2'
        log.request.should_not be_blank
        log.response.should_not be_blank
      end

      response = login_as :registrar2 do
        epp_plain_request(xml)
      end

      response[:result_code].should == '1000'
      domain.legal_documents.count.should == 1 # does not add another legal documen

      create_settings
    end

    it 'creates transfer successfully without legal document' do
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
      end
    end

    it 'transfers domain with contacts' do
      original_oc_id = domain.registrant.id
      original_oc_code = domain.registrant.code

      original_contact_codes = domain.contacts.pluck(:code)

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
      end

      # all domain contacts should be under registrar2 now
      domain.registrant.reload
      domain.registrant.registrar_id.should == @registrar2.id
      domain.registrant.id.should == original_oc_id

      # must generate new code
      domain.registrant.code.should_not == original_oc_code

      domain.contacts.each do |c|
        c.registrar_id.should == @registrar2.id
        original_contact_codes.include?(c.code).should_not == true
      end
    end

    it 'transfers domain when registrant has more domains' do
      Fabricate(:domain, registrant: domain.registrant)
      original_oc_id = domain.registrant.id
      original_oc_code = domain.registrant.code

      original_contact_codes = domain.contacts.pluck(:code)

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
      end

      # all domain contacts should be under registrar2 now
      domain.reload
      domain.registrant.registrar_id.should == @registrar2.id
      # registrant should be a new record
      domain.registrant.id.should_not == original_oc_id
      # must generate new code
      domain.registrant.code.should_not == original_oc_code

      domain.contacts.each do |c|
        c.registrar_id.should == @registrar2.id
        original_contact_codes.include?(c.code).should_not == true
      end
    end

    it 'transfers domain when registrant is admin or tech contact on some other domain' do
      d = Fabricate(:domain)
      d.tech_contacts << domain.registrant

      original_oc_id = domain.registrant.id
      original_oc_code = domain.registrant.code

      original_contact_codes = domain.contacts.pluck(:code)

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
      end

      # all domain contacts should be under registrar2 now
      domain.reload
      domain.registrant.registrar_id.should == @registrar2.id
      # registrant should be a new record
      domain.registrant.id.should_not == original_oc_id
      # must generate new code
      domain.registrant.code.should_not == original_oc_code

      domain.contacts.each do |c|
        c.registrar_id.should == @registrar2.id
        original_contact_codes.include?(c.code).should_not == true
      end
    end

    it 'transfers domain when domain contacts are some other domain contacts' do
      old_contact = Fabricate(:contact, registrar: @registrar1)
      domain.tech_contacts << old_contact
      domain.admin_contacts << old_contact

      d = Fabricate(:domain)
      d.tech_contacts << old_contact
      d.admin_contacts << old_contact
      original_oc_id = domain.registrant.id
      original_contact_count = Contact.count
      original_domain_contact_count = DomainContact.count

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
      end

      # all domain contacts should be under registrar2 now
      domain.reload
      domain.registrant.registrar_id.should == @registrar2.id
      # registrant should not be a new record
      domain.registrant.id.should == original_oc_id

      # old contact must not change
      old_contact.registrar_id.should == @registrar1.id

      domain.contacts.each do |x|
        x.registrar_id.should == @registrar2.id
      end

      new_contact = Contact.last
      new_contact.name.should == old_contact.name

      # there should be 2 references to the new contact
      domain.domain_contacts.where(contact_id: new_contact.id).count.should == 2

      # there should be only one new contact object
      (original_contact_count + 1).should == Contact.count

      # and no new references
      original_domain_contact_count.should == DomainContact.count
    end

    it 'transfers domain when multiple domain contacts are some other domain contacts' do
      old_contact = Fabricate(:contact, registrar: @registrar1, name: 'first')
      old_contact_2 = Fabricate(:contact, registrar: @registrar1, name: 'second')

      domain.tech_contacts << old_contact
      domain.admin_contacts << old_contact
      domain.tech_contacts << old_contact_2

      d = Fabricate(:domain)
      d.tech_contacts << old_contact
      d.admin_contacts << old_contact_2

      original_oc_id = domain.registrant.id
      original_contact_count = Contact.count
      original_domain_contact_count = DomainContact.count

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
      end

      # all domain contacts should be under registrar2 now
      domain.reload
      domain.registrant.registrar_id.should == @registrar2.id
      # registrant should not be a new record
      domain.registrant.id.should == original_oc_id

      # old contact must not change
      old_contact.registrar_id.should == @registrar1.id

      domain.contacts.each do |x|
        x.registrar_id.should == @registrar2.id
      end

      new_contact, new_contact_2 = Contact.last(2)

      # database does not follow always same order, thus we swap object when different order
      new_contact, new_contact_2 = new_contact_2, new_contact if new_contact.name != 'first'

      new_contact.name.should == old_contact.name
      new_contact_2.name.should == old_contact_2.name

      # there should be 2 references to the new contact (admin + tech)
      domain.domain_contacts.where(contact_id: new_contact.id).count.should == 2

      # there should be 1 reference to the new contact 2 (tech)
      domain.domain_contacts.where(contact_id: new_contact_2.id).count.should == 1

      # there should be only two new contact objects
      (original_contact_count + 2).should == Contact.count

      # and no new references
      original_domain_contact_count.should == DomainContact.count
    end

    it 'transfers domain and references exsisting registrant to domain contacts' do
      d = Fabricate(:domain)
      d.tech_contacts << domain.registrant

      domain.tech_contacts << domain.registrant
      original_registrant_id = domain.registrant_id

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
      end

      domain.reload
      # registrant must be an new record
      domain.registrant_id.should_not == original_registrant_id

      # new registrant must be a tech contact
      domain.domain_contacts.where(contact_id: domain.registrant_id).count.should == 1
    end

    it 'does not transfer contacts if they are already under new registrar' do
      domain.contacts.each do |c|
        c.registrar_id = @registrar2.id
        c.save
      end

      domain.registrant.registrar_id = @registrar2.id
      domain.registrant.save

      original_oc_id = domain.registrant_id
      original_oc_code = domain.registrant.code
      original_contacts_codes = domain.contacts.pluck(:code)

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
      end

      domain.reload

      domain.registrant.id.should == original_oc_id
      domain.registrant.code.should == original_oc_code
      domain.registrant.registrar_id.should == @registrar2.id

      original_contacts_codes.sort.should == domain.contacts.pluck(:code).sort
    end

    it 'should not creates transfer without password' do
      xml = domain_transfer_xml({
        name: { value: domain.name }
      })

      login_as :registrar2 do
        response = epp_plain_request(xml)
        response[:msg].should == 'Authorization error'
        response[:result_code].should == '2201'
      end
    end

    it 'approves the transfer request' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: @registrar2,
        transfer_from: @registrar1
      })

      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: domain.auth_info } }
      }, 'approve', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = epp_plain_request(xml)

      domain.reload
      dtl = domain.domain_transfers.last

      trn_data = response[:parsed].css('trnData')

      trn_data.css('name').text.should == domain.name
      trn_data.css('trStatus').text.should == 'clientApproved'
      trn_data.css('reID').text.should == 'REGDOMAIN2'
      trn_data.css('reDate').text.should == dtl.transfer_requested_at.in_time_zone.utc.utc.iso8601
      trn_data.css('acID').text.should == 'REGDOMAIN1'
      trn_data.css('exDate').text.should == domain.valid_to.in_time_zone.utc.utc.iso8601
    end

    it 'rejects a domain transfer' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: @registrar2,
        transfer_from: @registrar1
      })

      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }, 'reject', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = login_as :registrar2 do
        epp_plain_request(xml)
      end

      response[:msg].should == 'Transfer can be rejected only by current registrar'
      response[:result_code].should == '2304'
      domain.legal_documents.count.should == 0

      response = epp_plain_request(xml)
      response[:result_code].should == '1000'
      domain.pending_transfer.should be_nil
      domain.legal_documents.count.should == 1
    end

    it 'prohibits wrong registrar from approving transfer' do
      domain.domain_transfers.create({
        status: DomainTransfer::PENDING,
        transfer_requested_at: Time.zone.now,
        transfer_to: @registrar2,
        transfer_from: @registrar1
      })

      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: domain.auth_info } }
      }, 'approve', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = login_as :registrar2 do
        epp_plain_request(xml)
      end

      response[:result_code].should == '2304'
      response[:msg].should == 'Transfer can be approved only by current domain registrar'
    end

    it 'does not transfer with invalid pw' do
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: 'test' } }
      }, 'query', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = epp_plain_request(xml)
      response[:result_code].should == '2201'
      response[:msg].should == 'Authorization error'
    end

    it 'ignores transfer wha registrant registrar requests transfer' do
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }, 'query', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = epp_plain_request(xml)

      response[:result_code].should == '2002'
      response[:msg].should == 'Domain already belongs to the querying registrar'
    end

    it 'returns an error for incorrect op attribute' do
      response = epp_plain_request(domain_transfer_xml({}, 'bla'), validate_input: false)
      response[:result_code].should == '2306'
      response[:msg].should == 'Attribute is invalid: op'
    end

    it 'creates new pw after successful transfer' do
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }, 'query', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      login_as :registrar2 do
        epp_plain_request(xml) # transfer domain
        response =  epp_plain_request(xml) # attempt second transfer
        response[:msg].should == 'Authorization error'
        response[:result_code].should == '2201'
      end
    end

    it 'should get an error when there is no pending transfer' do
      pw = domain.auth_info
      xml = domain_transfer_xml({
        name: { value: domain.name },
        authInfo: { pw: { value: pw } }
      }, 'approve', {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = epp_plain_request(xml)
      response[:msg].should == 'Pending transfer was not found'
      response[:result_code].should == '2303'
    end

    ### UPDATE ###
    it 'should update right away without update pending status' do
      existing_pw = domain.auth_info

      xml_params = {
        name: { value: domain.name },
        chg: [
          registrant: { value: 'FIXED:CITIZEN_1234', attrs: { verified: 'yes' } }
        ]
      }

      response = epp_plain_request(domain_update_xml(xml_params, {}, {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }))

      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'

      d = Domain.last

      d.registrant_code.should == 'FIXED:CITIZEN_1234'
      d.auth_info.should == existing_pw
      d.pending_update?.should == false
    end

    # TODO: Remove this test if EIS decides not to create reserved status #2565
    # it 'should keep reserved status after reserved domain update' do
    #   domain.statuses = ['reserved']
    #   domain.save

    #   xml_params = {
    #     name: { value: domain.name },
    #     chg: [
    #       registrant: { value: 'FIXED:CITIZEN_1234', attrs: { verified: 'yes' } }
    #     ]
    #   }

    #   response = epp_plain_request(domain_update_xml(xml_params, {}, {
    #     _anonymus: [
    #       legalDocument: {
    #         value: 'dGVzdCBmYWlsCg==',
    #         attrs: { type: 'pdf' }
    #       }
    #     ]
    #   }))

    #   response[:results][0][:msg].should == 'Command completed successfully'
    #   response[:results][0][:result_code].should == '1000'

    #   d = Domain.last
    #   d.statuses.should match_array(['reserved'])
    # end

    it 'updates a domain' do
      existing_pw = domain.auth_info

      xml_params = {
        name: { value: domain.name },
        chg: [
          registrant: { value: 'FIXED:CITIZEN_1234' }
        ]
      }

      response = epp_plain_request(domain_update_xml(xml_params, {}, {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }))

      response[:results][0][:msg].should == 'Command completed successfully; action pending'
      response[:results][0][:result_code].should == '1001'

      d = Domain.last

      d.registrant_code.should_not == 'FIXED:CITIZEN_1234' # should not update
      d.auth_info.should == existing_pw
      d.pending_update?.should == true
    end

    it 'should not return action pending when changes are invalid' do
      existing_pw = domain.auth_info

      hostnames = domain.nameservers.pluck(:hostname)

      xml_params = {
        name: { value: domain.name },
        rem: [
          {
            ns:
              hostnames.map do |x|
                {
                  hostAttr: [
                    { hostName: { value: x } }
                  ]
                }
              end
          }
        ],
        chg: [
          registrant: { value: 'FIXED:CITIZEN_1234' }
        ]
      }

      response = epp_plain_request(domain_update_xml(xml_params, {}, {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }), :xml)

      response[:results][0][:msg].should == 'Nameservers count must be between 2-11 [nameservers]'
      response[:results][0][:result_code].should == '2004'

      d = Domain.last

      d.registrant_code.should_not == 'FIXED:CITIZEN_1234' # should not update
      d.auth_info.should == existing_pw
      d.nameservers.size == 3
      d.pending_update?.should == false
    end

    it 'should not return action pending when domain itself is already invaid' do
      domain_id = domain.id
      domain.nameservers.delete_all
      domain.save(validate: false)
      domain.reload.nameservers.size.should == 0

      existing_pw = domain.auth_info

      xml_params = {
        name: { value: domain.name },
        chg: [
          registrant: { value: 'FIXED:CITIZEN_1234' }
        ]
      }

      response = epp_plain_request(domain_update_xml(xml_params, {}, {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }), :xml)

      response[:results][0][:msg].should == 'Nameservers count must be between 2-11 [nameservers]'
      response[:results][0][:result_code].should == '2004'

      d = Domain.find(domain_id)

      d.registrant_code.should_not == 'FIXED:CITIZEN_1234' # should not update
      d.auth_info.should == existing_pw
      d.nameservers.size.should == 0
      d.pending_update?.should == false
    end

    it 'should not allow any update when status pending update' do
      domain.statuses << DomainStatus::PENDING_UPDATE
      domain.save

      existing_pw = domain.auth_info

      xml_params = {
        name: { value: domain.name },
        chg: [
          registrant: { value: 'FIXED:CITIZEN_1234' }
        ]
      }

      response = epp_plain_request(domain_update_xml(xml_params, {}, {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }))

      response[:results][0][:msg].should == 'Object status prohibits operation'
      response[:results][0][:result_code].should == '2304'

      d = Domain.last

      d.registrant_code.should_not == 'FIXED:CITIZEN_1234'
      d.auth_info.should == existing_pw
      d.pending_update?.should == true
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
            { contact: { value: 'FIXED:MAK21', attrs: { type: 'tech' } } },
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

      response = epp_plain_request(xml)
      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Contact was not found'

      Fabricate(:contact, code: 'FIXED:MAK21')

      response = epp_plain_request(xml)
      response[:results][0][:result_code].should == '1000'

      d = Domain.last

      new_ns_count = d.nameservers.where(hostname: ['ns1.example.com', 'ns2.example.com']).count
      new_ns_count.should == 2

      new_contact = d.tech_contacts.find_by(code: 'FIXED:MAK21')
      new_contact.should be_truthy

      d.statuses.count.should == 2
      d.statuses.include?('clientHold').should == true
      d.statuses.include?('clientUpdateProhibited').should == true

      d.dnskeys.count.should == 2

      response = epp_plain_request(xml)

      response[:results][0][:result_code].should == '2302'
      response[:results][0][:msg].should == 'Nameserver already exists on this domain [hostname]'
      if response[:results][0][:value] == 'ns1.example.com'
        response[:results][0][:value].should == 'ns1.example.com'
      else
        response[:results][0][:value].should == 'ns2.example.com'
      end

      response[:results][1][:result_code].should == '2302'
      response[:results][1][:msg].should == 'Nameserver already exists on this domain [hostname]'
      if response[:results][1][:value] == 'ns1.example.com'
        response[:results][1][:value].should == 'ns1.example.com'
      else
        response[:results][1][:value].should == 'ns2.example.com'
      end

      response[:results][2][:result_code].should == '2302'
      response[:results][2][:msg].should == 'Contact already exists on this domain [contact_code_cache]'
      response[:results][2][:value].should == 'FIXED:MAK21'

      # response[:results][3][:msg].should == 'Status already exists on this domain [value]'
      # if response[:results][3][:value] == 'clientHold'
      #   response[:results][3][:value].should == 'clientHold'
      # else
      #   response[:results][3][:value].should == 'clientUpdateProhibited'
      # end

      # response[:results][4][:msg].should == 'Status already exists on this domain [value]'
      # if response[:results][4][:value] == 'clientHold'
      #   response[:results][4][:value].should == 'clientHold'
      # else
      #   response[:results][4][:value].should == 'clientUpdateProhibited'
      # end

      response[:results][3][:msg].should == 'Public key already exists [public_key]'
      if response[:results][3][:value] == '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'
        response[:results][3][:value].should ==
          '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'
      else
        response[:results][3][:value].should ==
          '841936717ae427ace63c28d04918569a841936717ae427ace63c28d0'
      end

      response[:results][4][:msg].should == 'Public key already exists [public_key]'
      if response[:results][4][:value] == '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'
        response[:results][4][:value].should ==
          '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'
      else
        response[:results][4][:value].should ==
          '841936717ae427ace63c28d04918569a841936717ae427ace63c28d0'
      end

      d.statuses.count.should == 2
    end

    it 'updates domain with registrant change what triggers action pending' do
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
            { contact: { value: 'FIXED:PENDINGMAK21', attrs: { type: 'tech' } } },
            { status: { value: 'Payment overdue.', attrs: { s: 'clientHold', lang: 'en' } } },
            { status: { value: '', attrs: { s: 'clientUpdateProhibited' } } }
          ]
        ],
        chg: [
          registrant: { value: 'FIXED:CITIZEN_1234' }
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
      },
      {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      })

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Contact was not found'
      response[:results][0][:result_code].should == '2303'

      Fabricate(:contact, code: 'FIXED:PENDINGMAK21')

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully; action pending'
      response[:results][0][:result_code].should == '1001'

      d = Domain.last

      new_ns_count = d.nameservers.where(hostname: ['ns1.example.com', 'ns2.example.com']).count
      new_ns_count.should == 0 # aka old value

      new_contact = d.tech_contacts.find_by(code: 'FIXED:PENDINGMAK21')
      new_contact.should_not be_truthy # aka should not add new contact

      d.statuses.count.should == 1
      d.statuses.first.should == 'pendingUpdate'

      d.dnskeys.count.should == 0
    end

    it 'does not allow to edit statuses if policy forbids it' do
      Setting.client_status_editing_enabled = false

      xml = domain_update_xml({
        name: { value: domain.name },
        add: [{
          _anonymus: [
            { status: { value: 'Payment overdue.', attrs: { s: 'clientHold', lang: 'en' } } },
            { status: { value: '', attrs: { s: 'clientUpdateProhibited' } } }
          ]
        }]
      })

      response = epp_plain_request(xml)
      response[:results][0][:result_code].should == '2306'
      response[:results][0][:msg].should == "Parameter value policy error. Client-side object status "\
                                            "management not supported: status [status]"

      Setting.client_status_editing_enabled = true
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
            { contact: { value: 'FIXED:CITIZEN_1234', attrs: { type: 'tech' } } },
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

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'

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
            { contact: { value: 'FIXED:CITIZEN_1234', attrs: { type: 'tech' } } },
            { status: { value: '', attrs: { s: 'clientHold' } } }
          ]
        ]
      }, {
        rem: [
          { keyData: {
              flags: { value: '256' },
              protocol: { value: '3' },
              alg: { value: '254' },
              pubKey: { value: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f' }
            }
          }
        ]
      })

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'

      d.reload
      d.dnskeys.count.should == 1

      d.statuses.count.should == 1
      d.statuses.first.should == 'clientUpdateProhibited'

      rem_ns = d.nameservers.find_by(hostname: 'ns1.example.com')
      rem_ns.should be_falsey

      rem_cnt = d.tech_contacts.find_by(code: 'FIXED:CITIZEN_1234')
      rem_cnt.should be_falsey

      response = epp_plain_request(xml)

      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Nameserver was not found'
      response[:results][0][:value].should == 'ns1.example.com'

      response[:results][1][:result_code].should == '2303'
      response[:results][1][:msg].should == 'Contact was not found'
      response[:results][1][:value].should == 'FIXED:CITIZEN_1234'

      response[:results][2][:result_code].should == '2303'
      response[:results][2][:msg].should == 'DS was not found'
      response[:results][2][:value].should == '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'

      response[:results][3][:result_code].should == '2303'
      response[:results][3][:msg].should == 'Status was not found'
      response[:results][3][:value].should == 'clientHold'
    end

    it 'does not remove server statuses' do
      domain.statuses << DomainStatus::SERVER_HOLD
      domain.save

      xml = domain_update_xml({
        name: { value: domain.name },
        rem: [
          _anonymus: [
            { status: { value: '', attrs: { s: 'serverHold' } } }
          ]
        ]
      })

      response = epp_plain_request(xml)

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

      epp_plain_request(xml)
      response = epp_plain_request(xml)

      response[:results][0][:result_code].should == '2302'
      response[:results][0][:msg].should == 'Nameserver already exists on this domain [hostname]'
      response[:results][0][:value].should == n.hostname

      response[:results][1][:result_code].should == '2302'
      response[:results][1][:msg].should == 'Contact already exists on this domain [contact_code_cache]'
      response[:results][1][:value].should == c.code
    end

    it 'cannot change registrant without legal document' do
      xml_params = {
        name: { value: domain.name },
        chg: [
          registrant: { value: 'FIXED:CITIZEN_1234' }
        ]
      }

      response = epp_plain_request(domain_update_xml(xml_params))
      response[:results][0][:msg].should ==
        'Required parameter missing: extension > extdata > legalDocument [legal_document]'
      response[:results][0][:result_code].should == '2003'
    end

    it 'does not assign invalid status to domain' do
      xml = domain_update_xml({
        name: { value: domain.name },
        add: [
          status: { value: '', attrs: { s: 'invalidStatus' } }
        ]
      })

      response = epp_plain_request(xml, validate_input: false)
      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Status was not found'
      response[:results][0][:value].should == 'invalidStatus'
    end

    ### RENEW ###
    it 'renews a domain' do
      old_balance = @registrar1.balance
      old_activities = @registrar1.cash_account.account_activities.count

      domain.valid_to = Time.zone.now.to_date + 10.days
      domain.save

      exp_date = domain.valid_to.to_date
      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'

      ex_date = response[:parsed].css('renData exDate').text
      name = response[:parsed].css('renData name').text
      ex_date.should == "#{(exp_date + 1.year)}T00:00:00Z"
      name.should == domain.name

      @registrar1.balance.should == old_balance - 15.0
      @registrar1.cash_account.account_activities.count.should == old_activities + 1
      a = @registrar1.cash_account.account_activities.last
      a.description.should == "Renew #{Domain.last.name}"
      a.sum.should == -BigDecimal.new('15.0')
      a.activity_type = AccountActivity::RENEW
    end

    it 'renews a domain with 2 year period' do
      old_balance = @registrar1.balance
      old_activities = @registrar1.cash_account.account_activities.count

      domain.valid_to = Time.zone.now.to_date + 10.days
      domain.save

      exp_date = domain.valid_to.to_date
      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '730', attrs: { unit: 'd' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'

      ex_date = response[:parsed].css('renData exDate').text
      name = response[:parsed].css('renData name').text
      ex_date.should == "#{(exp_date + 2.year)}T00:00:00Z"
      name.should == domain.name

      @registrar1.balance.should == old_balance - 35.0
      @registrar1.cash_account.account_activities.count.should == old_activities + 1
      a = @registrar1.cash_account.account_activities.last
      a.description.should == "Renew #{Domain.last.name}"
      a.sum.should == -BigDecimal.new('35.0')
      a.activity_type = AccountActivity::CREATE
    end

    it 'renews a domain with 3 year period' do
      old_balance = @registrar1.balance
      old_activities = @registrar1.cash_account.account_activities.count

      domain.valid_to = Time.zone.now.to_date + 10.days
      domain.save

      exp_date = domain.valid_to.to_date
      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '36', attrs: { unit: 'm' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'

      ex_date = response[:parsed].css('renData exDate').text
      name = response[:parsed].css('renData name').text
      ex_date.should == "#{(exp_date + 3.year)}T00:00:00Z"
      name.should == domain.name

      @registrar1.balance.should == old_balance - 62.0
      @registrar1.cash_account.account_activities.count.should == old_activities + 1
      a = @registrar1.cash_account.account_activities.last
      a.description.should == "Renew #{Domain.last.name}"
      a.sum.should == -BigDecimal.new('62.0')
      a.activity_type = AccountActivity::CREATE
    end

    it 'does not renew a domain if credit balance low' do
      f = Fabricate(:pricelist, {
        valid_to: Time.zone.now + 1.day,
        operation_category: 'renew',
        duration: '1year',
        price: 100000
      })

      old_balance = @registrar1.balance
      old_activities = @registrar1.cash_account.account_activities.count

      domain.valid_to = Time.zone.now.to_date + 10.days
      domain.save

      exp_date = domain.valid_to.to_date
      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Billing failure - credit balance low'
      response[:results][0][:result_code].should == '2104'

      domain.reload
      domain.valid_to.should == exp_date # ensure domain was not renewed

      @registrar1.balance.should == old_balance
      @registrar1.cash_account.account_activities.count.should == old_activities
      f.delete
    end

    it 'returns an error when given and current exp dates do not match' do
      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: '2200-08-07' },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:result_code].should == '2306'
      response[:results][0][:msg].should == 'Given and current expire dates do not match'
    end

    it 'returns an error when period is invalid' do
      domain.valid_to = Time.zone.now.to_date + 10.days
      domain.save
      exp_date = domain.valid_to.to_date

      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '4', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Period must add up to 1, 2 or 3 years [period]'
      response[:results][0][:result_code].should == '2306'
      response[:results][0][:value].should == '4'
    end

    it 'does not renew a domain unless less than 90 days till expiration' do
      # both days are inclusive
      domain.valid_to = Time.zone.now.to_date + 90.days
      domain.save
      exp_date = domain.valid_to.to_date

      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Object is not eligible for renewal'
      response[:results][0][:result_code].should == '2105'

      domain.valid_to = Time.zone.now.to_date + 89.days
      domain.save
      exp_date = domain.valid_to.to_date

      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'
    end

    it 'does not renew a domain unless less than 90 days till expiration' do
      Setting.days_to_renew_domain_before_expire = 0

      domain.valid_to = Time.zone.now.to_date + 5.years
      domain.save
      exp_date = domain.valid_to.to_date

      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'
      Setting.days_to_renew_domain_before_expire = 90
    end

    it 'does not renew a domain if it is a delete candidate' do
      domain.valid_to = Time.zone.now + 10.days
      domain.delete_at = Time.zone.now
      domain.save

      Domain.start_delete_period

      exp_date = domain.valid_to.to_date

      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Object is not eligible for renewal'
      response[:results][0][:result_code].should == '2105'
    end

    it 'should renew a expired domain' do
      domain.valid_to = Time.zone.now - 50.days
      new_valid_to = domain.valid_to + 1.year
      domain.outzone_at = Time.zone.now - 50.days
      new_outzone_at = domain.outzone_at + 1.year
      new_delete_at = domain.delete_at + 1.year
      domain.save

      Domain.start_expire_period
      Domain.start_redemption_grace_period

      domain.reload
      domain.statuses.include?(DomainStatus::EXPIRED).should == true
      domain.statuses.include?(DomainStatus::SERVER_HOLD).should == true
      domain.statuses.include?(DomainStatus::OK).should == false

      exp_date = domain.valid_to.to_date

      xml = @epp_xml.domain.renew(
        name: { value: domain.name },
        curExpDate: { value: exp_date.to_s },
        period: { value: '1', attrs: { unit: 'y' } }
      )

      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'

      domain.reload
      domain.statuses.include?(DomainStatus::EXPIRED).should == false
      domain.statuses.include?(DomainStatus::SERVER_HOLD).should == false
      domain.statuses.include?(DomainStatus::OK).should == true

      domain.reload
      domain.valid_to.should be_within(5).of(new_valid_to)
      domain.outzone_at.should be_within(5).of(new_outzone_at)
      domain.delete_at.should be_within(5).of(new_delete_at)
    end

    it 'does not renew foreign domain' do
      login_as :registrar2 do
        exp_date = 1.year.since.to_date
        xml = @epp_xml.domain.renew(
          name: { value: domain.name },
          curExpDate: { value: exp_date.to_s },
          period: { value: '1', attrs: { unit: 'y' } }
        )

        response = epp_plain_request(xml)
        response[:results][0][:msg].should == 'Authorization error'
        response[:results][0][:result_code].should == '2201'
      end
    end

    ### INFO ###
    it 'returns domain info' do
      domain.statuses << DomainStatus::CLIENT_HOLD
      domain.nameservers.build(hostname: 'ns1.example.com', ipv4: '192.168.1.1', ipv6: '1080:0:0:0:8:800:200C:417A')

      domain.dnskeys.build(
        ds_key_tag: '123',
        ds_alg: 3,
        ds_digest_type: 1,
        ds_digest: '0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB',
        flags: 257,
        protocol: 3,
        alg: 3,
        public_key: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8'
      )

      domain.dnskeys.build(
        ds_key_tag: '123',
        ds_alg: 3,
        ds_digest_type: 1,
        ds_digest: '0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB',
        flags: 0,
        protocol: 3,
        alg: 5,
        public_key: '700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f'
      )

      domain.save

      xml = domain_info_xml(name: { value: domain.name })
      response = epp_plain_request(xml)
      response[:results][0][:msg].should == 'Command completed successfully'
      response[:results][0][:result_code].should == '1000'
      response[:clTRID].should be_nil

      inf_data = response[:parsed].css('resData infData')
      inf_data.css('name').text.should == domain.name
      inf_data.css('status').first[:s].should == 'clientHold'
      inf_data.css('registrant').text.should == domain.registrant_code
      inf_data.css('roid').text.should == domain.roid

      admin_contacts_from_request = inf_data.css('contact[type="admin"]').map(&:text)
      admin_contacts_existing = domain.admin_contacts.pluck(:code)

      admin_contacts_from_request.should == admin_contacts_existing

      hosts_from_request = inf_data.css('hostName').map(&:text)
      hosts_existing = domain.nameservers.pluck(:hostname).sort

      hosts_from_request.sort.should == hosts_existing

      ns1 = inf_data.css('hostAttr').last

      ns1.css('hostName').last.text.should == 'ns1.example.com'
      ns1.css('hostAddr').first.text.should == '192.168.1.1'
      ns1.css('hostAddr').last.text.should == '1080:0:0:0:8:800:200C:417A'
      inf_data.css('crDate').text.should == domain.created_at.in_time_zone.utc.utc.iso8601
      inf_data.css('exDate').text.should == domain.valid_to.in_time_zone.utc.utc.iso8601
      inf_data.css('pw').text.should == domain.auth_info

      ds_data_1 = response[:parsed].css('dsData')[0]

      ds_data_1.css('keyTag').first.text.should == '123'
      ds_data_1.css('alg').first.text.should == '3'
      ds_data_1.css('digestType').first.text.should == '1'
      ds_data_1.css('digest').first.text.should == '0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB'

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

      response = epp_plain_request(domain_info_xml(name: { value: domain.name }))
      inf_data = response[:parsed].css('resData infData')

      inf_data.css('upDate').text.should == domain.updated_at.in_time_zone.utc.utc.iso8601
    end

    it 'returns domain info with different nameservers' do
      domain.nameservers = []
      domain.save

      domain.nameservers.build(hostname: "ns1.#{domain.name}", ipv4: '192.168.1.1', ipv6: '1080:0:0:0:8:800:200C:417A')
      domain.nameservers.build(hostname: "ns2.#{domain.name}", ipv4: '192.168.1.1', ipv6: '1080:0:0:0:8:800:200C:417A')
      domain.nameservers.build(hostname: "ns3.test.ee", ipv4: '192.168.1.1', ipv6: '1080:0:0:0:8:800:200C:417A')
      domain.save

      xml = domain_info_xml(name: { value: domain.name, attrs: { hosts: 'invalid' } })
      response = epp_plain_request(xml, validate_input: false)
      response[:msg].should == 'Attribute is invalid: hosts'
      response[:result_code].should == '2306'

      xml = domain_info_xml(name: { value: domain.name, attrs: { hosts: 'sub' } })
      response = epp_plain_request(xml)

      inf_data = response[:parsed].css('resData infData')
      inf_data.css('hostAttr').count.should == 2
      inf_data.css('hostName').first.text.should == "ns1.#{domain.name}"
      inf_data.css('hostName').last.text.should == "ns2.#{domain.name}"

      xml = domain_info_xml(name: { value: domain.name, attrs: { hosts: 'del' } })
      response = epp_plain_request(xml)

      inf_data = response[:parsed].css('resData infData')
      inf_data.css('hostAttr').count.should == 1
      inf_data.css('hostName').first.text.should == "ns3.test.ee"

      xml = domain_info_xml(name: { value: domain.name, attrs: { hosts: 'none' } })
      response = epp_plain_request(xml)

      inf_data = response[:parsed].css('resData infData')
      inf_data.css('ns').count.should == 0
      inf_data.css('hostAttr').count.should == 0

      xml = domain_info_xml(name: { value: domain.name, attrs: { hosts: 'all' } })
      response = epp_plain_request(xml)

      inf_data = response[:parsed].css('resData infData')
      inf_data.css('hostAttr').count.should == 3
    end

    it 'returns error when domain can not be found' do
      response = epp_plain_request(domain_info_xml(name:  { value: 'test.ee' }))
      response[:results][0][:result_code].should == '2303'
      response[:results][0][:msg].should == 'Domain not found'
    end

    it 'sets ok status by default' do
      response = epp_plain_request(domain_info_xml(name: { value: domain.name }))
      inf_data = response[:parsed].css('resData infData')
      inf_data.css('status').first[:s].should == 'ok'
    end

    it 'can not see other registrar domains with invalid password' do
      login_as :registrar2 do
        response = epp_plain_request(domain_info_xml(name: { value: domain.name }))
        response[:result_code].should == '2201'
        response[:msg].should == 'Authorization error'
      end
    end

    it 'can see other registrar domains without password' do
      login_as :registrar2 do
        response = epp_plain_request(domain_info_xml(
          name: { value: domain.name },
          authInfo: nil
        ))

        response[:result_code].should == '1000'
        response[:parsed].css('authInfo pw').first.should == nil
      end
    end

    it 'can see other registrar domains with correct password' do
      login_as :registrar2 do
        pw = domain.auth_info
        response = epp_plain_request(domain_info_xml(
          name: { value: domain.name },
          authInfo: { pw: { value: pw } }
        ))

        response[:result_code].should == '1000'
        response[:parsed].css('authInfo pw').text.should == pw
      end
    end

    ### DELETE ###
    it 'deletes domain' do
      response = epp_plain_request(@epp_xml.domain.delete({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }))

      response[:msg].should == 'Command completed successfully; action pending'
      response[:result_code].should == '1001'

      Domain.find_by(name: domain.name).should_not == nil
    end

    it 'does not delete domain with specific status' do
      domain.statuses << DomainStatus::CLIENT_DELETE_PROHIBITED
      domain.save

      response = epp_plain_request(@epp_xml.domain.delete({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }))

      response[:result_code].should == '2304'
      response[:msg].should == 'Domain status prohibits operation'
    end

    it 'does not delete domain with pending delete' do
      domain.statuses << DomainStatus::PENDING_DELETE
      domain.save

      response = epp_plain_request(@epp_xml.domain.delete({
        name: { value: domain.name }
      }, {
        _anonymus: [
          legalDocument: {
            value: 'dGVzdCBmYWlsCg==',
            attrs: { type: 'pdf' }
          }
        ]
      }))

      response[:msg].should == 'Object status prohibits operation'
      response[:result_code].should == '2304'
    end

    it 'does not delete domain without legal document' do
      response = epp_plain_request(@epp_xml.domain.delete(name: { value: 'example.ee' }))
      response[:result_code].should == '2003'
      response[:msg].should ==
        'Required parameter missing: extension > extdata > legalDocument [legal_document]'
    end

    ### CHECK ###
    it 'checks a domain' do
      response = epp_plain_request(domain_check_xml({
        _anonymus: [
          { name: { value: 'one.ee' } }
        ]
      }))

      response[:result_code].should == '1000'
      response[:msg].should == 'Command completed successfully'

      res_data = response[:parsed].css('resData chkData cd name').first
      res_data.text.should == 'one.ee'
      res_data[:avail].should == '1'

      response = epp_plain_request(domain_check_xml({
        _anonymus: [
          { name: { value: domain.name } }
        ]
      }))
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

      response = epp_plain_request(xml)
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

      response = epp_plain_request(xml)
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
