module Epp
  # Example usage:
  #
  #    login_as :gitlab
  #
  # Use block for temp login:
  #
  #    login_as :registrar1 do
  #      your test code
  #      # will make request as registrar1 and logins back to previous session
  #    end
  #
  def login_as(user)
    server.open_connection

    if block_given?
      begin
        epp_plain_request(login_xml_for(user), :xml)
        yield
      ensure
        server.open_connection # return back to last login
        epp_plain_request(login_xml_for(@last_user), :xml)
      end
    else
      @last_user = user # save for block
      epp_plain_request(login_xml_for(user), :xml)
    end
  end

  def login_xml_for(user)
    @xml ||= EppXml.new(cl_trid: 'ABC-12345')
    case user
    when :gitlab
      @gitlab_login_xml ||=
        @xml.session.login(clID: { value: 'gitlab' }, pw: { value: 'ghyt9e4fu' })
    when :registrar1
      @registrar1_login_xml ||=
        @xml.session.login(clID: { value: 'registrar1' }, pw: { value: 'ghyt9e4fu' })
    when :registrar2
      @registrar2_login_xml ||=
        @xml.session.login(clID: { value: 'registrar2' }, pw: { value: 'ghyt9e4fu' })
    end
  end

  def read_body(filename)
    File.read("spec/epp/requests/#{filename}")
  end

  # handles connection and login automatically
  def epp_request(data, *args)
    server = server_zone
    server = server_elkdata if args.include?(:elkdata)

    res = parse_response(server.request(data)) if args.include?(:xml)
    if res
      log(data, res[:parsed])
      return res
    end

    res = parse_response(server.request(read_body(data)))
    log(read_body(data), res[:parsed])
    return res

  rescue => e
    e
  end

  def epp_plain_request(data, *args)
    options = args.extract_options!
    validate_input = options[:validate_input] != false # true by default
    validate_output = options[:validate_output] != false # true by default

    if validate_input && @xsd
      xml = Nokogiri::XML(data)
      @xsd.validate(xml).each do |error|
        fail Exception.new, error.to_s
      end
    end

    res = parse_response(server.send_request(data))
    if res
      log(data, res[:parsed])
      if validate_output && @xsd
        @xsd.validate(Nokogiri(res[:raw])).each do |error|
          fail Exception.new, error.to_s
        end
      end
      return res
    end
  rescue => e
    e
  end

  def server
    # tag and password not in use, add those at login xml
    @server ||= Epp::Server.new({ server: 'localhost', port: 701, tag: '', password: '' })
  end

  def parse_response(raw)
    res = Nokogiri::XML(raw)

    obj = {
      results: [],
      clTRID: res.css('epp trID clTRID').first.try(:text),
      parsed: res.remove_namespaces!,
      raw: raw
    }

    res.css('epp response result').each do |x|
      obj[:results] << {
        result_code: x[:code], msg: x.css('msg').text, value: x.css('value > *').try(:first).try(:text)
      }
    end

    obj[:result_code] = obj[:results][0][:result_code]
    obj[:msg] = obj[:results][0][:msg]

    obj
  end

  # print output
  def po(r)
    puts r[:parsed].to_s
  end

  def next_domain_name
    "example#{rand(100_000_000_000_000_000)}.ee"
  end

  ### REQUEST TEMPLATES ###

  def domain_info_xml(xml_params = {})
    defaults = {
      name: { value: next_domain_name, attrs: { hosts: 'all' } },
      authInfo: {
        pw: { value: '2fooBAR' }
      }
    }

    xml_params = defaults.deep_merge(xml_params)

    epp_xml = EppXml::Domain.new(cl_trid: false)
    epp_xml.info(xml_params)
  end

  # rubocop: disable Metrics/MethodLength
  def domain_create_xml(xml_params = {}, dnssec_params = {})
    defaults = {
      name: { value: next_domain_name },
      period: { value: '1', attrs: { unit: 'y' } },
      ns: [
        {
          hostAttr: [
            { hostName: { value: 'ns1.example.net' } },
            { hostAddr: { value: '192.0.2.2', attrs: { ip: 'v4' } } },
            { hostAddr: { value: '1080:0:0:0:8:800:200C:417A', attrs: { ip: 'v6' } } }
          ]
        },
        {
          hostAttr: {
            hostName: { value: 'ns2.example.net' }
          }
        }
      ],
      registrant: { value: 'FIXED:CITIZEN_1234' },
      _anonymus: [
        { contact: { value: 'FIXED:SH8013', attrs: { type: 'admin' } } },
        { contact: { value: 'FIXED:SH8013', attrs: { type: 'tech' } } },
        { contact: { value: 'FIXED:SH801333', attrs: { type: 'tech' } } }
      ]
    }

    xml_params = defaults.deep_merge(xml_params)

    dnssec_defaults = {
      _anonymus: [
        { keyData: {
          flags: { value: '257' },
          protocol: { value: '3' },
          alg: { value: '5' },
          pubKey: { value: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8' }
        }
      }]
    }

    dnssec_params = dnssec_defaults.deep_merge(dnssec_params) if dnssec_params != false

    custom_params = {
      _anonymus: [
        legalDocument: {
          value: 'dGVzdCBmYWlsCg==',
          attrs: { type: 'pdf' }
        }
      ]
    }

    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.create(xml_params, dnssec_params, custom_params)
  end

  def domain_create_xml_with_legal_doc(xml_params = {})
    defaults = {
      name: { value: next_domain_name },
      period: { value: '1', attrs: { unit: 'y' } },
      ns: [
        {
          hostAttr: [
            { hostName: { value: 'ns1.example.net' } },
            { hostAddr: { value: '192.0.2.2', attrs: { ip: 'v4' } } },
            { hostAddr: { value: '1080:0:0:0:8:800:200C:417A', attrs: { ip: 'v6' } } }
          ]
        },
        {
          hostAttr: {
            hostName: { value: 'ns2.example.net' }
          }
        }
      ],
      registrant: { value: 'FIXED:CITIZEN_1234' },
      _anonymus: [
        { contact: { value: 'FIXED:SH8013', attrs: { type: 'admin' } } },
        { contact: { value: 'FIXED:SH8013', attrs: { type: 'tech' } } },
        { contact: { value: 'FIXED:SH801333', attrs: { type: 'tech' } } }
      ]
    }

    xml_params = defaults.deep_merge(xml_params)

    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')

    epp_xml.create(xml_params, {}, {
      _anonymus: [
        legalDocument: {
          value: 'dGVzdCBmYWlsCg==',
          attrs: { type: 'pdf' }
        }
      ]
    })
  end

  def domain_create_with_invalid_ns_ip_xml
    xml_params = {
      name: { value: next_domain_name },
      period: { value: '1', attrs: { unit: 'y' } },
      ns: [
        {
          hostAttr: {
            hostName: { value: 'ns1.example.net' },
            hostAddr: { value: '192.0.2.2.invalid', attrs: { ip: 'v4' } }
          }
        },
        {
          hostAttr: {
            hostName: { value: 'ns2.example.net' },
            hostAddr: { value: 'invalid_ipv6', attrs: { ip: 'v6' } }
          }
        }
      ],
      registrant: { value: 'FIXED:CITIZEN_1234' },
      _anonymus: [
        { contact: { value: 'FIXED:SH8013', attrs: { type: 'admin' } } },
        { contact: { value: 'FIXED:SH8013', attrs: { type: 'tech' } } },
        { contact: { value: 'FIXED:SH801333', attrs: { type: 'tech' } } }
      ],
      authInfo: {
        pw: {
          value: '2fooBAR'
        }
      }
    }

    custom_params = {
      _anonymus: [
        legalDocument: {
          value: 'dGVzdCBmYWlsCg==',
          attrs: { type: 'pdf' }
        }
      ]
    }

    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.create(xml_params, {}, custom_params)
  end

  def domain_create_with_host_attrs
    xml_params = {
      name: { value: next_domain_name },
      period: { value: '1', attrs: { unit: 'y' } },
      ns: [
        {
          hostAttr: [
            { hostName: { value: 'ns1.example.net' } },
            { hostAddr: { value: '192.0.2.2', attrs: { ip: 'v4' } } },
            { hostAddr: { value: '1080:0:0:0:8:800:200C:417A', attrs: { ip: 'v6' } } }
          ]
        },
        {
          hostAttr: {
            hostName: { value: 'ns2.example.net' }
          }
        }
      ],
      registrant: { value: 'FIXED:CITIZEN_1234' },
      _anonymus: [
        { contact: { value: 'FIXED:SH8013', attrs: { type: 'admin' } } },
        { contact: { value: 'FIXED:SH8013', attrs: { type: 'tech' } } },
        { contact: { value: 'FIXED:SH801333', attrs: { type: 'tech' } } }
      ],
      authInfo: {
        pw: {
          value: '2fooBAR'
        }
      }
    }

    custom_params = {
      _anonymus: [
        legalDocument: {
          value: 'dGVzdCBmYWlsCg==',
          attrs: { type: 'pdf' }
        }
      ]
    }

    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.create(xml_params, {}, custom_params)
  end

  def domain_update_xml(xml_params = {}, dnssec_params = {}, custom_params = {})
    defaults = {
      name: { value: next_domain_name }
    }

    xml_params = defaults.deep_merge(xml_params)
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.update(xml_params, dnssec_params, custom_params)
  end

  def domain_check_xml(xml_params = {})
    defaults = {
      _anonymus: [
        { name: { value: next_domain_name } }
      ]
    }
    xml_params = defaults.deep_merge(xml_params)
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.check(xml_params)
  end

  def domain_transfer_xml(xml_params = {}, op = 'query', custom_params = {})
    defaults = {
      name: { value: next_domain_name },
      authInfo: {
        pw: { value: '98oiewslkfkd', attrs: { roid: 'citizen_1234-REP' } }
      }
    }

    xml_params = defaults.deep_merge(xml_params)
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.transfer(xml_params, op, custom_params)
  end

  def log(req, res)
    return unless ENV['EPP_DOC']
    puts "REQUEST:\n\n```xml\n#{Nokogiri(req)}```\n\n"
    puts "RESPONSE:\n\n```xml\n#{res}```\n\n"
  end
end

RSpec.configure do |c|
  c.include Epp, epp: true
end
