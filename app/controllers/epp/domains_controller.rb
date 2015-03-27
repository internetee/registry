class Epp::DomainsController < EppController
  skip_authorization_check # TODO: remove it

  before_action :find_domain, only: [:info, :renew, :update, :transfer, :delete]
  before_action :find_password, only: [:info, :update, :transfer, :delete]

  def create
    authorize! :create, Epp::Domain
    @domain = Epp::Domain.new_from_epp(params[:parsed_frame], current_user)

    if @domain.errors.any? || !@domain.save
      handle_errors(@domain)
    else
      render_epp_response '/epp/domains/create'
    end
  end

  def info
    authorize! :info, @domain, @password
    @hosts = params[:parsed_frame].css('name').first['hosts'] || 'all'

    case @hosts
    when 'del'
      @nameservers = @domain.delegated_nameservers
    when 'sub'
      @nameservers = @domain.subordinate_nameservers
    when 'all'
      @nameservers = @domain.nameservers
    end

    render_epp_response '/epp/domains/info'
  end

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

  # rubocop:disable Metrics/CyclomaticComplexity
  def update
    authorize! :update, @domain, @password

    if @domain.update(params[:parsed_frame], current_user)
      render_epp_response '/epp/domains/success'
    else
      handle_errors(@domain)
    end
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
  # rubocop:disable Metrics/CyclomaticComplexity

  def delete
    handle_errors(@domain) and return unless @domain.can_be_deleted?

    @domain.attach_legal_document(Epp::Domain.parse_legal_document_from_frame(params[:parsed_frame]))
    @domain.save(validate: false)

    handle_errors(@domain) and return unless @domain.destroy

    render_epp_response '/epp/domains/success'
  end
  # rubocop:enbale Metrics/CyclomaticComplexity

  private

  def validate_info
    @prefix = 'info > info >'
    requires('name')
    optional_attribute 'name', 'hosts', values: %(all, sub, del, none)
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
  end

  ## DELETE
  def validate_delete
    requires 'extension > extdata > legalDocument'

    @prefix = 'delete > delete >'
    requires 'name'
  end

  def find_domain
    domain_name = params[:parsed_frame].css('name').text.strip.downcase
    @domain = Epp::Domain.where(name: domain_name).first

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
end
