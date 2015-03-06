class Epp::DomainsController < EppController
  skip_authorization_check # TODO: remove it

  def create
    @domain = Epp::EppDomain.new(params[:parsed_frame], current_user)
    # @domain.parse_and_attach_domain_dependencies(params[:parsed_frame])
    # @domain.parse_and_attach_ds_data(params[:parsed_frame].css('extension create'))

    if @domain.errors.any? || !@domain.save
      handle_errors(@domain)
    else
      render_epp_response '/epp/domains/create'
    end
  end

  def info
    @domain = find_domain
    handle_errors(@domain) and return unless @domain
    render_epp_response '/epp/domains/info'
  end

  def check
    names = params[:parsed_frame].css('name').map(&:text)
    @domains = Epp::EppDomain.check_availability(names)
    render_epp_response '/epp/domains/check'
  end

  def renew
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.renew(
      params[:parsed_frame].css('curExpDate').text,
      params[:parsed_frame].css('period').text,
      params[:parsed_frame].css('period').first['unit']
    )

    render_epp_response '/epp/domains/renew'
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def update
    @domain = find_domain

    handle_errors(@domain) and return unless @domain

    # @domain.parse_and_detach_domain_dependencies(params[:parsed_frame].css('rem')
    # @domain.parse_and_detach_ds_data(params[:parsed_frame].css('extension rem'))
    # @domain.parse_and_attach_domain_dependencies(params[:parsed_frame].css('add'))
    # @domain.parse_and_attach_ds_data(params[:parsed_frame].css('extension add'))
    # @domain.parse_and_update_domain_dependencies(params[:parsed_frame].css('chg'))
    # @domain.attach_legal_document(Epp::EppDomain.parse_legal_document_from_frame(params[:parsed_frame]))

    # binding.pry

    # if @domain.update(parsed_frame)
    #   handle_errors(@domain)
    # else
    #   render_epp_response '/epp/domains/success'
    # end
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/MethodLength

  def transfer
    @domain = find_domain(secure: false)
    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.authenticate(domain_transfer_params[:pw])

    if domain_transfer_params[:action] == 'query'
      if @domain.pending_transfer
        @domain_transfer = @domain.pending_transfer
      else
        @domain_transfer = @domain.query_transfer(domain_transfer_params, params[:parsed_frame])
        handle_errors(@domain) and return unless @domain_transfer
      end
    elsif domain_transfer_params[:action] == 'approve'
      if @domain.pending_transfer
        @domain_transfer = @domain.approve_transfer(domain_transfer_params, params[:parsed_frame])
        handle_errors(@domain) and return unless @domain_transfer
      else
        epp_errors << { code: '2303', msg: I18n.t('pending_transfer_was_not_found') }
        handle_errors(@domain) and return
      end
    elsif domain_transfer_params[:action] == 'reject'
      if @domain.pending_transfer
        @domain_transfer = @domain.reject_transfer(domain_transfer_params, params[:parsed_frame])
        handle_errors(@domain) and return unless @domain_transfer
      else
        epp_errors << { code: '2303', msg: I18n.t('pending_transfer_was_not_found') }
        handle_errors(@domain) and return
      end
    end

    render_epp_response '/epp/domains/transfer'
  end

  # rubocop: enable Metrics/MethodLength
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/CyclomaticComplexity

  def delete
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.can_be_deleted?

    @domain.attach_legal_document(Epp::EppDomain.parse_legal_document_from_frame(params[:parsed_frame]))
    @domain.save(validate: false)

    handle_errors(@domain) and return unless @domain.destroy

    render_epp_response '/epp/domains/success'
  end
  # rubocop:enbale Metrics/CyclomaticComplexity

  private

  def validate_info
    @prefix = 'info > info >'
    requires('name')
  end

  def validate_check
    @prefix = 'check > check >'
    requires('name')
  end

  def validate_create
    @prefix = 'create > create >'
    requires 'name', 'ns', 'registrant', 'ns > hostAttr'

    @prefix = 'extension > create >'
    mutually_exclusive 'keyData', 'dsData'

    @prefix = nil
    requires 'extension > extdata > legalDocument'
  end

  def validate_renew
    @prefix = 'renew > renew >'
    requires 'name', 'curExpDate', 'period'
  end

  def validate_update
    if element_count('update > chg > registrant') > 0
      requires 'extension > extdata > legalDocument'
    end

    @prefix = 'update > update >'
    requires 'name'
  end

  ## TRANSFER
  def validate_transfer
    requires 'transfer > transfer'

    @prefix = 'transfer > transfer >'
    requires 'name'

    @prefix = nil
    requires_attribute 'transfer', 'op', values: %(approve, query, reject)

    requires 'extension > extdata > legalDocument'
  end

  ## DELETE
  def validate_delete
    requires 'extension > extdata > legalDocument'

    @prefix = 'delete > delete >'
    requires 'name'
  end

  def domain_rem_params
    ns_list = Epp::EppDomain.parse_nameservers_from_frame(params[:parsed_frame])

    to_destroy = []
    ns_list.each do |ns_attrs|
      nameserver = @domain.nameservers.where(ns_attrs).try(:first)
      if nameserver.blank?
        epp_errors << {
          code: '2303',
          msg: I18n.t('nameserver_not_found'),
          value: { obj: 'hostAttr', val: ns_attrs[:hostname] }
        }
      else
        to_destroy << {
          id: nameserver.id,
          _destroy: 1
        }
      end
    end

    {
      nameservers_attributes: to_destroy
    }
  end

  def domain_create_params
    period = params[:parsed_frame].css('period').text

    # registrant = parse_registrant(params)
    # domain_contacts = parse_domain_contacts_from_epp(params)

    registrant_code = params[:parsed_frame].css('registrant').text
    owner_contact = Contact.find_by(code: registrant_code)

    unless owner_contact
      epp_errors << {
        code: '2303',
        msg: I18n.t('registrant_not_found'),
        value: { obj: 'registrant', val: registrant_code }
      }
    end

    {
      name: params[:parsed_frame].css('name').text,
      registrar_id: current_user.registrar.try(:id),
      registered_at: Time.now,
      period: (period.to_i == 0) ? 1 : period.to_i,
      period_unit: Epp::EppDomain.parse_period_unit_from_frame(params[:parsed_frame]) || 'y',
      owner_contact_id: owner_contact.try(:id),
      nameservers_attributes: Epp::EppDomain.parse_nameservers_from_frame(params[:parsed_frame]),
      domain_contacts_attributes: parse_domain_contacts_from_epp,
      dnskeys_attributes: parse_dnskeys_from_frame(params[:parsed_frame].css('extension create')),
      legal_documents_attributes: parse_legal_document_from_frame(params[:parsed_frame])
    }
  end

  def parse_domain_contacts_from_epp
    res = []
    params[:parsed_frame].css('contact').each do |x|
      c = Contact.find_by(code: x.text).try(:id)

      unless c
        epp_errors << {
          code: '2303',
          msg: I18n.t('contact_not_found'),
          value: { obj: 'contact', val: x.text }
        }
        next
      end

      res << {
        contact_id: Contact.find_by(code: x.text).try(:id),
        contact_type: x['type'],
        contact_code_cache: x.text
      }
    end

    res
  end

  def parse_dnskeys_from_frame(parsed_frame)
    res = []
    # res = { ds_data: [], key_data: [] }

    # res[:max_sig_life] = parsed_frame.css('maxSigLife').first.try(:text)

    res = parse_ds_data_from_frame(parsed_frame, res)
    parse_key_data_from_frame(parsed_frame, res)
  end

  def parse_key_data_from_frame(parsed_frame, res)
    parsed_frame.xpath('keyData').each do |x|
      res << {
        flags: x.css('flags').first.try(:text),
        protocol: x.css('protocol').first.try(:text),
        alg: x.css('alg').first.try(:text),
        public_key: x.css('pubKey').first.try(:text),
        ds_alg: 3,
        ds_digest_type: Setting.ds_algorithm
      }
    end

    res
  end

  def parse_ds_data_from_frame(parsed_frame, res)
    parsed_frame.css('dsData').each do |x|
      data = {
        ds_key_tag: x.css('keyTag').first.try(:text),
        ds_alg: x.css('alg').first.try(:text),
        ds_digest_type: x.css('digestType').first.try(:text),
        ds_digest: x.css('digest').first.try(:text)
      }

      kd = x.css('keyData').first
      data.merge!({
        flags: kd.css('flags').first.try(:text),
        protocol: kd.css('protocol').first.try(:text),
        alg: kd.css('alg').first.try(:text),
        public_key: kd.css('pubKey').first.try(:text)
      }) if kd

      res << data
    end

    res
  end

  def parse_legal_document_from_frame(parsed_frame)
    ld = parsed_frame.css('legalDocument').first
    return [] unless ld

    [{
      body: ld.text,
      document_type: ld['type']
    }]
  end

  def domain_transfer_params
    res = {}
    res[:pw] = params[:parsed_frame].css('pw').first.try(:text)
    res[:action] = params[:parsed_frame].css('transfer').first[:op]
    res[:current_user] = current_user
    res
  end

  def find_domain(secure = { secure: true })
    domain_name = params[:parsed_frame].css('name').text.strip.downcase
    domain = Epp::EppDomain.find_by(name: domain_name)

    unless domain
      epp_errors << {
        code: '2303',
        msg: I18n.t('errors.messages.epp_domain_not_found'),
        value: { obj: 'name', val: domain_name }
      }
      return nil
    end

    return domain if domain.auth_info == params[:parsed_frame].css('authInfo pw').text

    if (domain.registrar != current_user.registrar) && secure[:secure] == true
      epp_errors << {
        code: '2302',
        msg: I18n.t('errors.messages.domain_exists_but_belongs_to_other_registrar'),
        value: { obj: 'name', val: params[:parsed_frame].css('name').text.strip.downcase }
      }
      return nil
    end

    domain
  end
end
