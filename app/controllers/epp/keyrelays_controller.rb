class Epp::KeyrelaysController < EppController
  skip_authorization_check # TODO: move authorization under ability

  def keyrelay
    # keyrelay temp turned off
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.authenticate(params[:parsed_frame].css('pw').text)
    handle_errors(@domain) and return unless @domain.keyrelay(params[:parsed_frame], current_user.registrar)

    render_epp_response '/epp/shared/success'
  end

  private

  def validate_keyrelay
    @prefix = 'keyrelay >'

    requires(
      'name',
      'keyData', 'keyData > pubKey', 'keyData > flags', 'keyData > protocol', 'keyData > alg',
      'authInfo', 'authInfo > pw'
    )

    optional 'expiry > relative', duration_iso8601: true
    optional 'expiry > absolute', date_time_iso8601: true

    exactly_one_of 'expiry > relative', 'expiry > absolute'
  end

  def find_domain
    domain_name = params[:parsed_frame].css('name').text.strip.downcase

    # keyrelay temp turned off
    epp_errors << {
      code: '2307',
      msg: I18n.t(:unimplemented_object_service),
      value: { obj: 'name', val: domain_name }
    }
    nil
    # end of keyrelay temp turned off

    # domain = Epp::Domain.includes(:registrant).find_by(name: domain_name)

    # unless domain
      # epp_errors << {
        # code: '2303',
        # msg: I18n.t('errors.messages.epp_domain_not_found'),
        # value: { obj: 'name', val: domain_name }
      # }
      # return nil
    # end

    # domain
  end

  def resource
    @domain
  end
end
