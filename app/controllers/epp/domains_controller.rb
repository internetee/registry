class Epp::DomainsController < EppController
  skip_authorization_check # TODO: remove it

  before_action :find_domain, only: [:info]
  before_action :find_password, only: [:info]

  def create
    authorize! :create, Epp::EppDomain
    @domain = Epp::EppDomain.new_from_epp(params[:parsed_frame], current_user)

    if @domain.errors.any? || !@domain.save
      handle_errors(@domain)
    else
      render_epp_response '/epp/domains/create'
    end
  end

  def info
    authorize! :info, @domain, @password
    render_epp_response '/epp/domains/info'
  end

  def check
    authorize! :check, Epp::EppDomain

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

    if @domain.update(params[:parsed_frame], current_user)
      render_epp_response '/epp/domains/success'
    else
      handle_errors(@domain)
    end
  end

  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/MethodLength

  def transfer
    @domain = find_domain
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

  def domain_transfer_params
    res = {}
    res[:pw] = params[:parsed_frame].css('pw').first.try(:text)
    res[:action] = params[:parsed_frame].css('transfer').first[:op]
    res[:current_user] = current_user
    res
  end

  def find_domain
    domain_name = params[:parsed_frame].css('name').text.strip.downcase
    @domain = Epp::EppDomain.find_by(name: domain_name)

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


# return domain if domain.auth_info == params[:parsed_frame].css('authInfo pw').text

#     if (domain.registrar != current_user.registrar) && secure[:secure] == true
#       epp_errors << {
#         code: '2302',
#         msg: I18n.t('errors.messages.domain_exists_but_belongs_to_other_registrar'),
#         value: { obj: 'name', val: params[:parsed_frame].css('name').text.strip.downcase }
#       }
#       return nil
#     end

#     domain
