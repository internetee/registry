module Epp::DomainsHelper
  def create_domain
    Domain.transaction do
      @domain = Domain.new(domain_create_params)

      handle_errors(@domain) and return unless @domain.parse_and_attach_domain_dependencies(@ph, parsed_frame)
      handle_errors(@domain) and return unless @domain.save

      render '/epp/domains/create'
    end
  end

  def check_domain
    ph = params_hash['epp']['command']['check']['check']
    @domains = Domain.check_availability(ph[:name])
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
    Domain.transaction do
      @domain = find_domain

      handle_errors(@domain) and return unless @domain

      @domain.parse_and_attach_domain_dependencies(@ph, parsed_frame.css('add'))
      @domain.parse_and_detach_domain_dependencies(parsed_frame.css('rem'))
      @domain.parse_and_update_domain_dependencies(parsed_frame.css('chg'))
      @domain.parse_and_update_domain_attributes(parsed_frame.css('chg'))

      if @domain.errors.any?
        handle_errors(@domain)
        raise ActiveRecord::Rollback and return
      end

      unless @domain.save
        handle_errors(@domain)
        raise ActiveRecord::Rollback and return
      end

      render '/epp/domains/success'
    end
  end

  def transfer_domain
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.transfer(domain_transfer_params)

    render '/epp/domains/transfer'
  end

  ### HELPER METHODS ###

  private

  ## CREATE
  def validate_domain_create_request
    @ph = params_hash['epp']['command']['create']['create']
    xml_attrs_present?(@ph, [['name'], ['ns'], ['authInfo'], ['contact'], ['registrant']])
  end

  def domain_create_params
    period = (@ph[:period].to_i == 0) ? 1 : @ph[:period].to_i
    period_unit = Domain.parse_period_unit_from_frame(parsed_frame) || 'y'
    valid_to = Date.today + Domain.convert_period_to_time(period, period_unit)

    {
      name: @ph[:name],
      registrar_id: current_epp_user.registrar.try(:id),
      registered_at: Time.now,
      period: (@ph[:period].to_i == 0) ? 1 : @ph[:period].to_i,
      period_unit: Domain.parse_period_unit_from_frame(parsed_frame) || 'y',
      valid_from: Date.today,
      valid_to: valid_to,
      auth_info: @ph[:authInfo][:pw]
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
    xml_attrs_present?(@ph, [['name']])
  end

  ## SHARED
  def find_domain
    domain = Domain.find_by(name: @ph[:name])
    unless domain
      epp_errors << { code: '2303', msg: I18n.t('errors.messages.epp_domain_not_found'), value: { obj: 'name', val: @ph[:name] } }
    end
    domain
  end
end
