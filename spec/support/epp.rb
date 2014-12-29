module Epp
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
    server = server_gitlab
    server = server_elkdata if args.include?(:elkdata)
    server = server_zone if args.include?(:zone)

    res = parse_response(server.send_request(data)) if args.include?(:xml)
    if res
      log(data, res[:parsed])
      return res
    end

    res = parse_response(server.send_request(read_body(data)))
    log(read_body(data), res[:parsed])
    return res
  rescue => e
    e
  end

  def parse_response(raw)
    res = Nokogiri::XML(raw)

    obj = {
      results: [],
      clTRID: res.css('epp trID clTRID').text,
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

  ### REQUEST TEMPLATES ###

  def domain_info_xml(xml_params = {})
    defaults = {
      name: { value: 'example.ee', attrs: { hosts: 'all' } },
      authInfo: {
        pw: { value: '2fooBAR' }
      }
    }

    xml_params = defaults.deep_merge(xml_params)

    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.info(xml_params)
  end

  # rubocop: disable Metrics/MethodLength
  def domain_create_xml(xml_params = {}, dnssec_params = {})
    defaults = {
      name: { value: 'example.ee' },
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
      registrant: { value: 'jd1234' },
      _anonymus: [
        { contact: { value: 'sh8013', attrs: { type: 'admin' } } },
        { contact: { value: 'sh8013', attrs: { type: 'tech' } } },
        { contact: { value: 'sh801333', attrs: { type: 'tech' } } }
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
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.create(xml_params, dnssec_params)
  end

  def domain_create_xml_with_legal_doc
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')

    epp_xml.create({
      name: { value: 'example.ee' },
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
      registrant: { value: 'jd1234' },
      _anonymus: [
        { contact: { value: 'sh8013', attrs: { type: 'admin' } } },
        { contact: { value: 'sh8013', attrs: { type: 'tech' } } },
        { contact: { value: 'sh801333', attrs: { type: 'tech' } } }
      ]
    }, {}, {
      _anonymus: [
        legalDocument: { value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp'\
'bHRlci9GbGF0ZURlY29kZT4+CnN0cmVhbQp4nCWKsQrCMBRF9/cVdxaavBfz'\
'mhZCBrEKbsGAg7hZuymNg79vRO5yOOeyEXxoBYMb6ajGYfBiBtSZLhs8/62t'\
'LrQrpH1LIfh2LnfYg0AcyuMaWVIIkV2SyNvUucg+dRpZuefwk0Nqbky3cqKp'\
'UKaMFXY6nhXLG7ZUj/0Lmb7IGR/MCmVuZHN0cmVhbQplbmRvYmoKCjMgMCBv'\
'YmoKMTMwCmVuZG9iagoKNCAwIG9iago8PC9UeXBlL1hPYmplY3QKL1N1YnR5'\
'cGUvRm9ybQovQkJveFsgLTExMiA0MjAgNzA4IDQyMC4xIF0KL0dyb3VwPDwv'\
'Uy9UcmFuc3BhcmVuY3kvQ1MvRGV2aWNlUkdCL0sgdHJ1ZT4+Ci9MZW5ndGgg'\
'OAovRmlsdGVyL0ZsYXRlRGVjb2RlCj4+CnN0cmVhbQp4nAMAAAAAAQplbmRz'\
'dHJlYW0KZW5kb2JqCgo1IDAgb2JqCjw8L0NBIDAuNQogICAvY2EgMC41Cj4+'\
'CmVuZG9iagoKNyAwIG9iago8PC9MZW5ndGggOCAwIFIvRmlsdGVyL0ZsYXRl'\
'RGVjb2RlL0xlbmd0aDEgODQ0ND4+CnN0cmVhbQp4nOVYfVBbV3Y/970noQ9A'\
'EpZknoXRk5/Fh4UkQMZgm4AASQiDgzCQCBxAMhKg2HxYkp11nKzZTZx45bh2'\
's9t81G7jpNtOJtkZP+y0QzZpTKbZdjqbxJvZzW63G2/c2Z1pZ2Jqb5pkduLY'\
'9NwngT822Z3pdqZ/9CK9d87vfNxzzj33vofSyX1xyIdZYME7OhmdWVegVQHA'\
'2wCkaHR/Wlhq9QpIXwJgzGMz45MVnl/8JwD7W4A8xfieA2P/oGu9DqBFE01k'\
'Ih6NHaj/eg2AKYLApgkEum8cyEP+GeTXT0ymv/ZjrnM18q8jX7ZnejS6Rfsf'\
'hcj/GnnzZPRrM3+lPMwh/wXywlR0Mr49/vx3UFQCoOqamU6lY7B+CaB0gspn'\
'kvGZTwefxnhLj2B8acQI/tGRj6SS8gzLKZR5KjX8Px2KY2CCoOIu0MGMfL1t'\
'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'\
'0SzHcns+/5dzs7k3HRvO+CVjTh15g+TR/xLl63nCeQfIpevkwnUiXCeHrpHQ'\
'NTL78YmPmd9crbSeuXr+KtN9ZeTKmSts9RWiu0JUsKhfDC1GFmcWTy8qNbrL'\
'JB8+IoZfXWqwfui52P9Lzwf9cJE0hi7OXpQusvT9bvCiShu4SNj+D1izVb8g'\
'LFQvzCzMLvxo4dLC1QXV7Bsn3mD+/nW3Vfe69XXGeq773KFzbORFonvR+iIT'\
'Ohk5yZw4RXSnrKfcp9g/f9Zlfba91Pr0U+XWS09dfYqh7uueKjAERv6MHHry'\
'+JPMzGOzj514jJ09fOIwc2b/+f1MKlRpnZ5yWKfaN1h5T3F/noftV7JL8ou2'\
'b5e9IhAZ8VpHUGnnYLV1sL3SuspT1K/AYDlU1LFWtpntZqfZ4+x5Nk+1I1Rq'\
'7cHvpdDVEKPrtna7u+X/k6KdNnS0bWbb7Da2I1BpDbY3WHXt1nZ3+4X2D9uv'\
'tCtH2slz+AmcCZwPsN5ApTvgDZTaAiVBS7/ZY+rXe3T9DIF+4oF+t25Jx+h0'\
'I7pDOlaH/8kzs2aiIPPkxFxfr8PROZ+3tKNTUoV2SuSIZO+lV2/PoKQ8IkH/'\
'4M7wHCF/MnD42DFoXdsp1faGpcjagU4phoSXErNI6NfOmaF1IJVKO+jAV20k'\
'9+EVHPsQGk5lQXAsi8GRIqkUpFLEQWUyiQikHBSmCLUhaDmcAnqhUoesRalU'\
'qnj4vwGYP7CyCmVuZHN0cmVhbQplbmRvYmoKCjggMCBvYmoKNTE1NQplbmRv'\
'YmoKCjkgMCBvYmoKPDwvVHlwZS9Gb250RGVzY3JpcHRvci9Gb250TmFtZS9C'\
'QUFBQUErTGliZXJhdGlvblNlcmlmCi9GbGFncyA0Ci9Gb250QkJveFstMTc2'\
'IC0zMDMgMTAwNSA5ODFdL0l0YWxpY0FuZ2xlIDAKL0FzY2VudCA4OTEKL0Rl'\
'c2NlbnQgLTIxNgovQ2FwSGVpZ2h0IDk4MQovU3RlbVYgODAKL0ZvbnRGaWxl'\
'MiA3IDAgUgo+PgplbmRvYmoKCjEwIDAgb2JqCjw8L0xlbmd0aCAyNjMvRmls'\
'dGVyL0ZsYXRlRGVjb2RlPj4Kc3RyZWFtCnicXZDNasQgFIX3PoXL6WLQZCaZ'\
'BoJQUgay6A9N+wBGb1KhUTFmkbevP9MWulC+yz1H77mk6x97rTx5dUYM4PGk'\
'tHSwms0JwCPMSqOixFIJf6vSLRZuEQneYV89LL2eTNsi8hZ6q3c7PjxIM8Id'\
'Ii9OglN6xoePbgj1sFn7BQtojyliDEuYwjtP3D7zBUhyHXsZ2srvx2D5E7zv'\
'FnCZ6iKPIoyE1XIBjusZUEspw+31yhBo+a/XZMc4iU/ugrIISkqrMwtcJq6r'\
'yKfEl1Pkc+akqRKXNHKd9XXkS+Yi8n3mJnKTuUuz3H6NU8W1/aTFYnMuJE27'\
'TRFjOKXhd/3W2OhK5xucIn/9CmVuZHN0cmVhbQplbmRvYmoKCjExIDAgb2Jq'\
'Cjw8L1R5cGUvRm9udC9TdWJ0eXBlL1RydWVUeXBlL0Jhc2VGb250L0JBQUFB'\
'QStMaWJlcmF0aW9uU2VyaWYKL0ZpcnN0Q2hhciAwCi9MYXN0Q2hhciA5Ci9X'\
'aWR0aHNbMzY1IDYxMCA0NDMgMzg5IDI3NyAyNTAgMzMzIDQ0MyAyNzcgMjc3'\
'IF0KL0ZvbnREZXNjcmlwdG9yIDkgMCBSCi9Ub1VuaWNvZGUgMTAgMCBSCj4+'\
'CmVuZG9iagoKMTIgMCBvYmoKPDwvRjEgMTEgMCBSCj4+CmVuZG9iagoKMTMg'\
'MCBvYmoKPDwvRm9udCAxMiAwIFIKL1hPYmplY3Q8PC9UcjQgNCAwIFI+Pgov'\
'RXh0R1N0YXRlPDwvRUdTNSA1IDAgUj4+Ci9Qcm9jU2V0Wy9QREYvVGV4dC9J'\
'bWFnZUMvSW1hZ2VJL0ltYWdlQl0KPj4KZW5kb2JqCgoxIDAgb2JqCjw8L1R5'\
'cGUvUGFnZS9QYXJlbnQgNiAwIFIvUmVzb3VyY2VzIDEzIDAgUi9NZWRpYUJv'\
'eFswIDAgNTk1IDg0Ml0vR3JvdXA8PC9TL1RyYW5zcGFyZW5jeS9DUy9EZXZp'\
'Y2VSR0IvSSB0cnVlPj4vQ29udGVudHMgMiAwIFI+PgplbmRvYmoKCjYgMCBv'\
'YmoKPDwvVHlwZS9QYWdlcwovUmVzb3VyY2VzIDEzIDAgUgovTWVkaWFCb3hb'\
'IDAgMCA1OTUgODQyIF0KL0tpZHNbIDEgMCBSIF0KL0NvdW50IDE+PgplbmRv'\
'YmoKCjE0IDAgb2JqCjw8L1R5cGUvQ2F0YWxvZy9QYWdlcyA2IDAgUgovT3Bl'\
'bkFjdGlvblsxIDAgUiAvWFlaIG51bGwgbnVsbCAwXQovTGFuZyhlbi1VUykK'\
'Pj4KZW5kb2JqCgoxNSAwIG9iago8PC9DcmVhdG9yPEZFRkYwMDU3MDA3MjAw'\
'NjkwMDc0MDA2NTAwNzI+Ci9Qcm9kdWNlcjxGRUZGMDA0QzAwNjkwMDYyMDA3'\
'MjAwNjUwMDRGMDA2NjAwNjYwMDY5MDA2MzAwNjUwMDIwMDAzNDAwMkUwMDMy'\
'PgovQ3JlYXRpb25EYXRlKEQ6MjAxNDEyMjkxMjM5MTkrMDInMDAnKT4+CmVu'\
'ZG9iagoKeHJlZgowIDE2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwNjYw'\
'MiAwMDAwMCBuIAowMDAwMDAwMDE5IDAwMDAwIG4gCjAwMDAwMDAyMjAgMDAw'\
'MDAgbiAKMDAwMDAwMDI0MCAwMDAwMCBuIAowMDAwMDAwNDE5IDAwMDAwIG4g'\
'CjAwMDAwMDY3NDUgMDAwMDAgbiAKMDAwMDAwMDQ1OSAwMDAwMCBuIAowMDAw'\
'MDA1Njk4IDAwMDAwIG4gCjAwMDAwMDU3MTkgMDAwMDAgbiAKMDAwMDAwNTkx'\
'NCAwMDAwMCBuIAowMDAwMDA2MjQ3IDAwMDAwIG4gCjAwMDAwMDY0NDQgMDAw'\
'MDAgbiAKMDAwMDAwNjQ3NyAwMDAwMCBuIAowMDAwMDA2ODQ0IDAwMDAwIG4g'\
'CjAwMDAwMDY5NDEgMDAwMDAgbiAKdHJhaWxlcgo8PC9TaXplIDE2L1Jvb3Qg'\
'MTQgMCBSCi9JbmZvIDE1IDAgUgovSUQgWyA8MTM0NjQ3Qzk5NTQ5RDA2RTZB'\
'RUI5ODBDOERCRENBRUM+CjwxMzQ2NDdDOTk1NDlEMDZFNkFFQjk4MEM4REJE'\
'Q0FFQz4gXQovRG9jQ2hlY2tzdW0gLzFDNzgzNDRCNkIxRTEzQjlBQ0Y0NTlC'\
'OEExMzZDNEY1Cj4+CnN0YXJ0eHJlZgo3MTE2CiUlRU9GCg==', attrs: { type: 'pdf' } }
      ]
    })
  end

  def domain_create_with_invalid_ns_ip_xml
    xml_params = {
      name: { value: 'example.ee' },
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
      registrant: { value: 'jd1234' },
      contact: { value: 'sh8013', attrs: { type: 'admin' } },
      contact: { value: 'sh8013', attrs: { type: 'tech' } },
      contact: { value: 'sh801333', attrs: { type: 'tech' } },
      authInfo: {
        pw: {
          value: '2fooBAR'
        }
      }
    }

    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.create(xml_params, false)
  end

  def domain_create_with_host_attrs
    xml_params = {
      name: { value: 'example.ee' },
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
      registrant: { value: 'jd1234' },
      contact: { value: 'sh8013', attrs: { type: 'admin' } },
      contact: { value: 'sh8013', attrs: { type: 'tech' } },
      contact: { value: 'sh801333', attrs: { type: 'tech' } },
      authInfo: {
        pw: {
          value: '2fooBAR'
        }
      }
    }

    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.create(xml_params, false)
  end

  def domain_update_xml(xml_params = {}, dnssec_params = false)
    defaults = {
      name: { value: 'example.ee' }
    }

    xml_params = defaults.deep_merge(xml_params)
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.update(xml_params, dnssec_params)
  end

  def domain_check_xml(xml_params = {})
    defaults = {
      _anonymus: [
        { name: { value: 'example.ee' } }
      ]
    }
    xml_params = defaults.deep_merge(xml_params)
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.check(xml_params)
  end

  def domain_transfer_xml(xml_params = {}, op = 'query')
    defaults = {
      name: { value: 'example.ee' },
      authInfo: {
        pw: { value: '98oiewslkfkd', attrs: { roid: 'JD1234-REP' } }
      }
    }

    xml_params = defaults.deep_merge(xml_params)
    epp_xml = EppXml::Domain.new(cl_trid: 'ABC-12345')
    epp_xml.transfer(xml_params, op)
  end

  def log(req, res)
    return unless ENV['EPP_DOC']
    puts "REQUEST:

    ```xml
    #{Nokogiri(req)}```

    "
    puts "RESPONSE:

    ```xml
    #{res}```

    "
  end
end

RSpec.configure do |c|
  c.include Epp, epp: true
end
