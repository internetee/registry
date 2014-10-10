module Epp::DomainsHelper
  def create_domain
    Epp::EppDomain.transaction do
      @domain = Epp::EppDomain.new(domain_create_params)

      @domain.parse_and_attach_domain_dependencies(parsed_frame)

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
    handle_errors(@domain) and return unless @domain.renew(@ph[:curExpDate], @ph[:period])

    render '/epp/domains/renew'
  end

  def info_domain
    @domain = find_domain

    handle_errors(@domain) and return unless @domain

    render '/epp/domains/info'
  end

  def update_domain
    Epp::EppDomain.transaction do
      @domain = find_domain

      handle_errors(@domain) and return unless @domain

      @domain.parse_and_attach_domain_dependencies(parsed_frame.css('add'))
      @domain.parse_and_detach_domain_dependencies(parsed_frame.css('rem'))
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

  def transfer_domain
    @domain = find_domain(secure: false)

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.transfer(domain_transfer_params)

    render '/epp/domains/transfer'
  end

  def delete_domain
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.can_be_deleted?
    handle_errors(@domain) and return unless @domain.destroy

    render '/epp/domains/success'
  end

  ### HELPER METHODS ###

  private

  ## CREATE
  def validate_domain_create_request
    @ph = params_hash['epp']['command']['create']['create']
    # TODO: Verify contact presence if registrant is juridical
    xml_attrs_present?(@ph, [['name'], ['ns'], ['registrant']])
  end

  def domain_create_params
    {
      name: @ph[:name],
      registrar_id: current_epp_user.registrar.try(:id),
      registered_at: Time.now,
      period: (@ph[:period].to_i == 0) ? 1 : @ph[:period].to_i,
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
    domain = Epp::EppDomain.find_by(name: @ph[:name])

    unless domain
      epp_errors << { code: '2303', msg: I18n.t('errors.messages.epp_domain_not_found'), value: { obj: 'name', val: @ph[:name] } }
      return nil
    end

    if domain.registrar != current_epp_user.registrar && secure[:secure] == true
      epp_errors << { code: '2302', msg: I18n.t('errors.messages.domain_exists_but_belongs_to_other_registrar'), value: { obj: 'name', val: @ph[:name] } }
      return nil
    end

    domain
  end
end
