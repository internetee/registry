class Epp::DomainsController < ApplicationController
  include Epp::Common

  def create
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

  private

  def validate_check
    epp_request_valid?('name')
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

    if (domain.registrar != current_epp_user.registrar && secure[:secure] == true) &&
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
