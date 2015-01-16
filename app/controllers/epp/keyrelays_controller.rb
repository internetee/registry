class Epp::KeyrelaysController < EppController
  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def keyrelay
    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.authenticate(params[:parsed_frame].css('pw').text)
    handle_errors(@domain) and return unless @domain.keyrelay(params[:parsed_frame], current_epp_user.registrar)

    render_epp_response '/epp/shared/success'
  end

  private

  def validate_keyrelay
    epp_request_valid?('pubKey', 'flags', 'protocol', 'alg', 'name', 'pw')

    begin
      abs_datetime = params[:parsed_frame].css('absolute').text
      abs_datetime = DateTime.parse(abs_datetime) if abs_datetime.present?
    rescue => _e
      epp_errors << {
        code: '2005',
        msg: I18n.t('unknown_expiry_absolute_pattern'),
        value: { obj: 'expiry_absolute', val: abs_datetime }
      }
    end

    epp_errors.empty?
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def find_domain
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

    domain
  end
end
