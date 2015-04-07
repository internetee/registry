module Depp
  class Domain
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :name, :current_user, :epp_xml

    DOMAIN_STATUSES = %w(
      clientDeleteProhibited
      clientHold
      clientRenewProhibited
      clientTransferProhibited
      clientUpdateProhibited
    )

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
      xml = epp_xml.create({
        name: { value: domain_params[:name] },
        registrant: { value: domain_params[:registrant] },
        period: { value: domain_params[:period], attrs: { unit: domain_params[:period_unit] } },
        ns: Domain.create_nameservers_hash(domain_params),
        _anonymus: Domain.create_contacts_hash(domain_params)
      }, {
        _anonymus: Domain.create_dnskeys_hash(domain_params)
      }, Domain.construct_custom_params_hash(domain_params))

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
        name: { value: domain_params[:name] }
      }, Depp::Domain.construct_custom_params_hash(domain_params))

      current_user.request(xml)
    end

    def renew(params)
      current_user.request(epp_xml.renew(
        name: { value: params[:domain_name] },
        curExpDate: { value: params[:cur_exp_date] },
        period: { value: params[:period], attrs: { unit: params[:period_unit] } }
      ))
    end

    def transfer(params)
      op = params[:query] ? 'query' : nil
      op = params[:approve] ? 'approve' : op
      op = params[:reject] ? 'reject' : op

      current_user.request(epp_xml.transfer({
        name: { value: params[:domain_name] },
        authInfo: { pw: { value: params[:password] } }
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

      def construct_params_from_server_data(data) # rubocop:disable Metrics/MethodLength
        ret = default_params
        ret[:name] = data.css('name').text
        ret[:registrant] = data.css('registrant').text

        data.css('contact').each_with_index do |x, i|
          ret[:contacts_attributes][i] = { code: x.text, type: x['type'] }
        end

        data.css('hostAttr').each_with_index do |x, i|
          ret[:nameservers_attributes][i] = {
            hostname: x.css('hostName').text,
            ipv4: x.css('hostAddr[ip="v4"]').text,
            ipv6: x.css('hostAddr[ip="v6"]').text
           }
        end

        data.css('dsData').each_with_index do |x, i|
          ds = {
            ds_key_tag: x.css('keyTag').first.try(:text),
            ds_alg: x.css('alg').first.try(:text),
            ds_digest_type: x.css('digestType').first.try(:text),
            ds_digest: x.css('digest').first.try(:text)
          }

          kd = x.css('keyData').first
          ds.merge!({
            flags: kd.css('flags').first.try(:text),
            protocol: kd.css('protocol').first.try(:text),
            alg: kd.css('alg').first.try(:text),
            public_key: kd.css('pubKey').first.try(:text)
          }) if kd

          ret[:dnskeys_attributes][i] = ds
        end

        data.css('status').each_with_index do |x, i|
          next unless DOMAIN_STATUSES.include?(x['s'])
          ret[:statuses_attributes][i] = {
            code: x['s'],
            description: x.text
          }
        end

        ret
      end

      def construct_custom_params_hash(domain_params)
        custom_params = {}
        if domain_params[:legal_document].present?
          type = domain_params[:legal_document].original_filename.split('.').last.downcase
          custom_params = {
            _anonymus: [
              legalDocument: { value: Base64.encode64(domain_params[:legal_document].read), attrs: { type:  type } }
            ]
          }
        end

        custom_params
      end

      def construct_edit_hash(domain_params, old_domain_params)
        contacts = create_contacts_hash(domain_params) - create_contacts_hash(old_domain_params)
        statuses = create_statuses_hash(domain_params) - create_statuses_hash(old_domain_params)
        add_anon = contacts + statuses

        contacts = create_contacts_hash(old_domain_params) - create_contacts_hash(domain_params)
        statuses = create_statuses_hash(old_domain_params) - create_statuses_hash(domain_params)
        rem_anon = contacts + statuses

        if domain_params[:registrant] != old_domain_params[:registrant]
          chg = [{ registrant: { value: domain_params[:registrant] } }]
        end

        {
          name: { value: domain_params[:name] },
          chg: chg,
          add: [
            { ns: create_nameservers_hash(domain_params) - create_nameservers_hash(old_domain_params) },
            { _anonymus: add_anon }
          ],
          rem: [
            { ns: create_nameservers_hash(old_domain_params) - create_nameservers_hash(domain_params) },
            { _anonymus: rem_anon }
          ]
        }
      end

      def construct_ext_edit_hash(domain_params, old_domain_params)
        {
          add: create_dnskeys_hash(domain_params) - create_dnskeys_hash(old_domain_params),
          rem: create_dnskeys_hash(old_domain_params) - create_dnskeys_hash(domain_params)
        }
      end

      def create_nameservers_hash(domain_params)
        ret = []
        domain_params[:nameservers_attributes].each do |_k, v|
          next if v['hostname'].blank?

          host_attr = []
          host_attr << { hostName: { value: v['hostname'] } }
          host_attr << { hostAddr: { value: v['ipv4'], attrs: { ip: 'v4' } } } if v['ipv4'].present?
          host_attr << { hostAddr: { value: v['ipv6'], attrs: { ip: 'v6' } } } if v['ipv6'].present?

          ret <<  { hostAttr: host_attr }
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
            ret <<  {
              keyData: kd
            } if kd
          else
            ret <<  {
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

      def create_statuses_hash(domain_params)
        ret = []
        domain_params[:statuses_attributes].each do |_k, v|
          next if v['code'].blank?
          ret << {
            status: { value: v['description'], attrs: { s: v['code'] } }
          }
        end

        ret
      end
    end
  end
end
