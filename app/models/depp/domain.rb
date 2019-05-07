module Depp
  class Domain
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :name, :current_user, :epp_xml

    STATUSES = %w(
      clientDeleteProhibited
      clientHold
      clientRenewProhibited
      clientTransferProhibited
      clientUpdateProhibited
    )

    PERIODS = [
      ['3 months', '3m'],
      ['6 months', '6m'],
      ['9 months', '9m'],
      ['1 year', '1y'],
      ['2 years', '2y'],
      ['3 years', '3y'],
      ['4 years', '4y'],
      ['5 years', '5y'],
      ['6 years', '6y'],
      ['7 years', '7y'],
      ['8 years', '8y'],
      ['9 years', '9y'],
      ['10 years', '10y'],
    ]

    def initialize(args = {})
      self.current_user = args[:current_user]
      self.epp_xml = EppXml::Domain.new(cl_trid_prefix: current_user.tag)
    end

    def info(domain_name)
      xml = epp_xml.info(name: { value: domain_name })
      current_user.request(xml)
    end

    def check(domain_name)
      xml = epp_xml.check(
        _anonymus: [
          name: { value: domain_name }
        ]
      )
      current_user.request(xml)
    end

    def create(domain_params)
      dns_hash = {}
      keys = Domain.create_dnskeys_hash(domain_params)
      dns_hash[:_anonymus] = keys if keys.any?

      period = domain_params[:period].to_i.to_s
      period_unit = domain_params[:period][-1].to_s

      if domain_params[:nameservers_attributes].select { |key, value| value['hostname'].present? }.any?
        xml = epp_xml.create({
          name: { value: domain_params[:name] },
          period: { value: period, attrs: { unit: period_unit } },
          ns: Domain.create_nameservers_hash(domain_params),
          registrant: { value: domain_params[:registrant] },
          _anonymus: Domain.create_contacts_hash(domain_params)
        }, dns_hash, Domain.construct_custom_params_hash(domain_params))
      else
        xml = epp_xml.create({
          name: { value: domain_params[:name] },
          period: { value: period, attrs: { unit: period_unit } },
          registrant: { value: domain_params[:registrant] },
          _anonymus: Domain.create_contacts_hash(domain_params)
        }, dns_hash, Domain.construct_custom_params_hash(domain_params))
      end

      current_user.request(xml)
    end

    def update(domain_params)
      data = current_user.request(epp_xml.info(name: { value: domain_params[:name] }))
      old_domain_params = Depp::Domain.construct_params_from_server_data(data)

      xml = epp_xml.update(
        Depp::Domain.construct_edit_hash(domain_params, old_domain_params),
        Depp::Domain.construct_ext_edit_hash(domain_params, old_domain_params),
        Depp::Domain.construct_custom_params_hash(domain_params)
      )

      current_user.request(xml)
    end

    def delete(domain_params)
      xml = epp_xml.delete({
        name: { value: domain_params[:name] }},
        Depp::Domain.construct_custom_params_hash(domain_params),
        (domain_params[:verified].present? && 'yes'))

      current_user.request(xml)
    end

    def renew(params)
      period = params[:period].to_i.to_s
      period_unit = params[:period][-1].to_s

      current_user.request(epp_xml.renew(
        name: { value: params[:domain_name] },
        curExpDate: { value: params[:cur_exp_date] },
        period: { value: period, attrs: { unit: period_unit } }
      ))
    end

    def transfer(params)
      op = params[:request] ? 'request' : nil
      op = params[:query] ? 'query' : op
      op = params[:approve] ? 'approve' : op
      op = params[:reject] ? 'reject' : op

      current_user.request(epp_xml.transfer({
        name: { value: params[:domain_name] },
        authInfo: { pw: { value: params[:transfer_code] } }
      }, op, Domain.construct_custom_params_hash(params)))
    end

    def confirm_keyrelay(domain_params)
      xml = epp_xml.update({
        name: { value: domain_params[:name] }
      }, {
        add: Domain.create_dnskeys_hash(domain_params)
      })

      current_user.request(xml)
    end

    def confirm_transfer(domain_params)
      data = current_user.request(epp_xml.info(name: { value: domain_params[:name] }))
      pw = data.css('pw').text

      xml = epp_xml.transfer({
        name: { value: domain_params[:name] },
        authInfo: { pw: { value: pw } }
      }, 'approve')

      current_user.request(xml)
    end

    class << self
      def default_period
        '1y'
      end

      def default_params
        ret = {}

        ret[:contacts_attributes] ||= {}
        ENV['default_admin_contacts_count'].to_i.times do |i|
          ret[:contacts_attributes][i] = { code: '', type: 'admin' }
        end

        ret[:nameservers_attributes] ||= {}
        ENV['default_nameservers_count'].to_i.times do |i|
          ret[:nameservers_attributes][i] = {}
        end

        ret[:dnskeys_attributes] ||= { 0 => {} }
        ret[:statuses_attributes] ||= { 0 => {} }
        ret.with_indifferent_access
      end

      def construct_params_from_server_data(data)
        ret = default_params
        ret[:name] = data.css('name').text
        ret[:registrant] = data.css('registrant').text

        data.css('contact').each_with_index do |x, i|
          ret[:contacts_attributes][i] = { code: x.text, type: x['type'] }
        end

        data.css('hostAttr').each_with_index do |x, i|
          ret[:nameservers_attributes][i] = {
            hostname: x.css('hostName').text,
            ipv4: Array(x.css('hostAddr[ip="v4"]')).map(&:text).join(','),
            ipv6: Array(x.css('hostAddr[ip="v6"]')).map(&:text).join(',')
           }
        end

        data.css('keyData').each_with_index do |x, i|
          ret[:dnskeys_attributes][i] = {
              flags: x.css('flags').text,
              protocol: x.css('protocol').text,
              alg: x.css('alg').text,
              public_key: x.css('pubKey').text,
              ds_key_tag: x.css('keyTag').first.try(:text),
              ds_alg: x.css('alg').first.try(:text),
              ds_digest_type: x.css('digestType').first.try(:text),
              ds_digest: x.css('digest').first.try(:text)
          }
        end

        data.css('status').each_with_index do |x, i|
          next unless STATUSES.include?(x['s'])
          ret[:statuses_attributes][i] = {
            code: x['s'],
            description: x.text
          }
        end

        ret
      end

      def construct_custom_params_hash(domain_params)
        custom_params = { _anonymus: [] }
        if domain_params[:legal_document].present?
          type = domain_params[:legal_document].original_filename.split('.').last.downcase
          custom_params[:_anonymus] << {
            legalDocument: { value: Base64.encode64(domain_params[:legal_document].read), attrs: { type:  type } }
          }
        end

        if domain_params[:reserved_pw].present?
          custom_params[:_anonymus] << { reserved: { pw: { value: domain_params[:reserved_pw] } } }
        end

        custom_params
      end

      def construct_edit_hash(domain_params, old_domain_params)
        contacts = array_difference(create_contacts_hash(domain_params), create_contacts_hash(old_domain_params))
        add_anon = contacts

        contacts = array_difference(create_contacts_hash(old_domain_params), create_contacts_hash(domain_params))
        rem_anon = contacts

        add_arr = []
        add_ns = create_nameservers_hash(domain_params) - create_nameservers_hash(old_domain_params)
        add_arr << { ns: add_ns } if add_ns.any?
        add_arr << { _anonymus: add_anon } if add_anon.any?

        rem_arr = []
        rem_ns = create_nameservers_hash(old_domain_params) - create_nameservers_hash(domain_params)
        rem_arr << { ns: rem_ns } if rem_ns.any?
        rem_arr << { _anonymus: rem_anon } if rem_anon.any?

        if domain_params[:registrant] != old_domain_params[:registrant]
          chg = [{ registrant: { value: domain_params[:registrant] } }] if !domain_params[:verified].present?
          chg = [{ registrant: { value: domain_params[:registrant], attrs: { verified: 'yes' } } }] if domain_params[:verified]
        end

        add_arr = nil if add_arr.none?
        rem_arr = nil if rem_arr.none?

        {
          name: { value: domain_params[:name] },
          add: add_arr,
          rem: rem_arr,
          chg: chg
        }
      end

      def construct_ext_edit_hash(domain_params, old_domain_params)
        rem_keys = create_dnskeys_hash(old_domain_params) - create_dnskeys_hash(domain_params)
        add_keys = create_dnskeys_hash(domain_params) - create_dnskeys_hash(old_domain_params)
        hash = {}
        hash[:rem] = rem_keys if rem_keys.any?
        hash[:add] = add_keys if add_keys.any?
        hash
      end

      def create_nameservers_hash(domain_params)
        ret = []
        domain_params[:nameservers_attributes].each do |_k, v|
          next if v['hostname'].blank?

          host_attr = []
          host_attr << { hostName: { value: v['hostname'] } }
          v['ipv4'].to_s.split(",").each do |ip|
            host_attr << { hostAddr: { value: ip, attrs: { ip: 'v4' } } }
          end if v['ipv4'].present?

          v['ipv6'].to_s.split(",").each do |ip|
            host_attr << { hostAddr: { value: ip, attrs: { ip: 'v6' } } }
          end if v['ipv6'].present?

          ret << { hostAttr: host_attr }
        end

        ret
      end

      def create_contacts_hash(domain_params)
        ret = []
        domain_params[:contacts_attributes].each do |_k, v|
          next if v['code'].blank?
          ret << {
            contact: { value: v['code'], attrs: { type: v['type'] } }
          }
        end

        ret
      end

      def create_dnskeys_hash(domain_params)
        ret = []
        domain_params[:dnskeys_attributes].each do |_k, v|
          if v['ds_key_tag'].blank?
            kd = create_key_data_hash(v)
            ret << {
              keyData: kd
            } if kd
          else
            ret << {
              dsData: [
                keyTag: { value: v['ds_key_tag'] },
                alg: { value: v['ds_alg'] },
                digestType: { value: v['ds_digest_type'] },
                digest: { value: v['ds_digest'] },
                keyData: create_key_data_hash(v)
              ]
            }
          end
        end

        ret
      end

      def create_key_data_hash(key_data_params)
        return nil if key_data_params['public_key'].blank?
        {
          flags: { value: key_data_params['flags'] },
          protocol: { value: key_data_params['protocol'] },
          alg: { value: key_data_params['alg'] },
          pubKey: { value: key_data_params['public_key'] }
        }
      end

      def array_difference(x, y)
        ret = x.dup
        y.each do |element|
          index = ret.index(element)
          ret.delete_at(index) if index
        end
        ret
      end
    end
  end
end
