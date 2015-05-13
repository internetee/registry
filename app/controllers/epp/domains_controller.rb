class Epp::DomainsController < EppController
  before_action :find_domain, only: [:info, :renew, :update, :transfer, :delete]
  before_action :find_password, only: [:info, :update, :transfer, :delete]

  def info
    authorize! :info, @domain, @password
    @hosts = params[:parsed_frame].css('name').first['hosts'] || 'all'

    case @hosts
    when 'del'
      @nameservers = @domain.delegated_nameservers.sort
    when 'sub'
      @nameservers = @domain.subordinate_nameservers.sort
    when 'all'
      @nameservers = @domain.nameservers.sort
    end

    render_epp_response '/epp/domains/info'
  end

  def create
    authorize! :create, Epp::Domain
    @domain = Epp::Domain.new_from_epp(params[:parsed_frame], current_user)

    if @domain.errors.any? || !@domain.save
      handle_errors(@domain)
    else
      render_epp_response '/epp/domains/create'
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def update
    authorize! :update, @domain, @password

    if @domain.update(params[:parsed_frame], current_user)
      if @domain.pending_update?
        render_epp_response '/epp/domains/success_pending'
      else
        render_epp_response '/epp/domains/success'
      end
    else
      handle_errors(@domain)
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def delete
    authorize! :delete, @domain, @password

    # all includes for bullet
    @domain = Epp::Domain.where(id: @domain.id).includes(nameservers: :versions).first

    handle_errors(@domain) and return unless @domain.can_be_deleted?

    @domain.attach_legal_document(Epp::Domain.parse_legal_document_from_frame(params[:parsed_frame]))
    @domain.save(validate: false)

    handle_errors(@domain) and return unless @domain.destroy

    render_epp_response '/epp/domains/success'
  end
  # rubocop:enbale Metrics/CyclomaticComplexity

  def check
    authorize! :check, Epp::Domain

    names = params[:parsed_frame].css('name').map(&:text)
    @domains = Epp::Domain.check_availability(names)
    render_epp_response '/epp/domains/check'
  end

  def renew
    authorize! :renew, Epp::Domain

    handle_errors(@domain) and return unless @domain.renew(
      params[:parsed_frame].css('curExpDate').text,
      params[:parsed_frame].css('period').text,
      params[:parsed_frame].css('period').first['unit']
    )

    render_epp_response '/epp/domains/renew'
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/MethodLength
  def transfer
    authorize! :transfer, @domain, @password
    action = params[:parsed_frame].css('transfer').first[:op]

    @domain_transfer = @domain.transfer(params[:parsed_frame], action, current_user)

    if @domain.errors.empty? && @domain_transfer
      render_epp_response '/epp/domains/transfer'
    else
      handle_errors(@domain)
    end
  end
  # rubocop: enable Metrics/MethodLength
  # rubocop: enable Metrics/CyclomaticComplexity

  private

  def validate_info
    @prefix = 'info > info >'
    requires('name')
    optional_attribute 'name', 'hosts', values: %(all, sub, del, none)
  end

  def validate_create
    @prefix = 'create > create >'
    requires 'name', 'ns', 'registrant', 'ns > hostAttr'

    @prefix = 'extension > create >'
    mutually_exclusive 'keyData', 'dsData'

    @prefix = nil
    requires 'extension > extdata > legalDocument'

    status_editing_disabled
  end

  def validate_update
    if element_count('update > chg > registrant') > 0
      requires 'extension > extdata > legalDocument'
    end

    @prefix = 'update > update >'
    requires 'name'

    status_editing_disabled
  end

  def validate_delete
    requires 'extension > extdata > legalDocument'

    @prefix = 'delete > delete >'
    requires 'name'
  end

  def validate_check
    @prefix = 'check > check >'
    requires('name')
  end

  def validate_renew
    @prefix = 'renew > renew >'
    requires 'name', 'curExpDate', 'period'
  end

  def validate_transfer
    requires 'transfer > transfer'

    @prefix = 'transfer > transfer >'
    requires 'name'

    @prefix = nil
    requires_attribute 'transfer', 'op', values: %(approve, query, reject)
  end

  def find_domain
    domain_name = params[:parsed_frame].css('name').text.strip.downcase
    @domain = Epp::Domain.where(name: domain_name).includes(registrant: :registrar).first

    unless @domain
      epp_errors << {
        code: '2303',
        msg: I18n.t('errors.messages.epp_domain_not_found'),
        value: { obj: 'name', val: domain_name }
      }
      fail CanCan::AccessDenied
    end

    @domain
  end

  def find_password
    @password = params[:parsed_frame].css('authInfo pw').text
  end

  def status_editing_disabled
    return true if Setting.client_status_editing_enabled
    return true if params[:parsed_frame].css('status').empty?
    epp_errors << {
      code: '2306',
      msg: "#{I18n.t(:client_side_status_editing_error)}: status [status]"
    }
  end
end
