module Epp::DomainsHelper
  def create_domain
    Epp::EppDomain.transaction do
      @domain = Epp::EppDomain.new(domain_create_params)

      @domain.parse_and_attach_domain_dependencies(parsed_frame)
      @domain.parse_and_attach_ds_data(parsed_frame.css('extension create'))

      if @domain.errors.any?
        handle_errors(@domain)
        fail ActiveRecord::Rollback and return
      end

      unless @domain.save
        handle_errors(@domain)
        fail ActiveRecord::Rollback and return
      end

      render '/epp/domains/create'
    end
  end

  def check_domain
    ph = params_hash['epp']['command']['check']['check']
    @domains = Epp::EppDomain.check_availability(ph[:name])
    render '/epp/domains/check'
  end

  def renew_domain
    # TODO: support period unit
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.renew(
      parsed_frame.css('curExpDate').text,
      parsed_frame.css('period').text,
      parsed_frame.css('period').first['unit']
    )

    render '/epp/domains/renew'
  end

  def info_domain
    @domain = find_domain

    handle_errors(@domain) and return unless @domain

    render '/epp/domains/info'
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def update_domain
    Epp::EppDomain.transaction do
      @domain = find_domain

      handle_errors(@domain) and return unless @domain

      @domain.parse_and_detach_domain_dependencies(parsed_frame.css('rem'))
      @domain.parse_and_detach_ds_data(parsed_frame.css('extension rem'))
      @domain.parse_and_attach_domain_dependencies(parsed_frame.css('add'))
      @domain.parse_and_attach_ds_data(parsed_frame.css('extension add'))
      @domain.parse_and_update_domain_dependencies(parsed_frame.css('chg'))

      if @domain.errors.any?
        handle_errors(@domain)
        fail ActiveRecord::Rollback and return
      end

      unless @domain.save
        handle_errors(@domain)
        fail ActiveRecord::Rollback and return
      end

      render '/epp/domains/success'
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def transfer_domain
    @domain = find_domain(secure: false)

    handle_errors(@domain) and return unless @domain

    @domain_transfer = @domain.transfer(domain_transfer_params)
    handle_errors(@domain) and return unless @domain_transfer

    render '/epp/domains/transfer'
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def delete_domain
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.can_be_deleted?
    handle_errors(@domain) and return unless @domain.destroy

    render '/epp/domains/success'
  end
  # rubocop:enbale Metrics/CyclomaticComplexity

  ### HELPER METHODS ###

  private

  ## CREATE
  def validate_domain_create_request
    @ph = params_hash['epp']['command']['create']['create']
    # TODO: Verify contact presence if registrant is juridical
    attrs_present = xml_attrs_present?(@ph, [['name'], ['ns'], ['registrant']])
    return false unless attrs_present

    if parsed_frame.css('dsData').count > 0 && parsed_frame.css('create > keyData').count > 0
      epp_errors << { code: '2306', msg: I18n.t('shared.ds_data_and_key_data_must_not_exists_together') }
      return false
    end
    true
  end

  def domain_create_params
    name = parsed_frame.css('name').text
    period = parsed_frame.css('period').text

    {
      name: name,
      registrar_id: current_epp_user.registrar.try(:id),
      registered_at: Time.now,
      period: (period.to_i == 0) ? 1 : period.to_i,
      period_unit: Epp::EppDomain.parse_period_unit_from_frame(parsed_frame) || 'y'
    }
  end

  def domain_transfer_params
    res = {}
    res[:pw] = parsed_frame.css('pw').first.try(:text)
    res[:action] = parsed_frame.css('transfer').first[:op]
    res[:current_user] = current_epp_user
    res
  end

  ## RENEW
  def validate_domain_renew_request
    @ph = params_hash['epp']['command']['renew']['renew']
    xml_attrs_present?(@ph, [['name'], ['curExpDate'], ['period']])
  end

  ## INFO
  def validate_domain_info_request
    @ph = params_hash['epp']['command']['info']['info']
    xml_attrs_present?(@ph, [['name']])
  end

  ## UPDATE
  def validate_domain_update_request
    @ph = params_hash['epp']['command']['update']['update']
    xml_attrs_present?(@ph, [['name']])
  end

  ## TRANSFER
  def validate_domain_transfer_request
    @ph = params_hash['epp']['command']['transfer']['transfer']
    attrs_present = xml_attrs_present?(@ph, [['name']])
    return false unless attrs_present

    op = parsed_frame.css('transfer').first[:op]
    return true if %w(approve query).include?(op)
    epp_errors << { code: '2306', msg: I18n.t('errors.messages.attribute_op_is_invalid') }
    false
  end

  ## DELETE
  def validate_domain_delete_request
    @ph = params_hash['epp']['command']['delete']['delete']
    xml_attrs_present?(@ph, [['name']])
  end

  ## SHARED
  def find_domain(secure = { secure: true })
    domain_name = parsed_frame.css('name').text.strip.downcase
    domain = Epp::EppDomain.find_by(name: domain_name)

    unless domain
      epp_errors << {
        code: '2303',
        msg: I18n.t('errors.messages.epp_domain_not_found'),
        value: { obj: 'name', val: domain_name }
      }
      return nil
    end

    @ph[:authInfo] ||= {}
    return domain if domain.auth_info == @ph[:authInfo][:pw]

    if (domain.registrar != current_epp_user.registrar && secure[:secure] == true) &&
      epp_errors << {
        code: '2302',
        msg: I18n.t('errors.messages.domain_exists_but_belongs_to_other_registrar'),
        value: { obj: 'name', val: @ph[:name].strip.downcase }
      }
      return nil
    end

    domain
  end
end
