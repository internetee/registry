module Epp::KeyrelayHelper
  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def keyrelay
    handle_errors and return unless validate_keyrelay_request

    @domain = find_domain_for_keyrelay

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.authenticate(parsed_frame.css('pw').text)
    handle_errors(@domain) and return unless @domain.keyrelay(parsed_frame, current_epp_user.registrar)

    render '/epp/shared/success'
  end

  private

  def validate_keyrelay_request
    epp_request_valid?('pubKey', 'flags', 'protocol', 'algorithm', 'name', 'pw')

    begin
      abs_datetime = parsed_frame.css('absolute').text
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

  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  def find_domain_for_keyrelay
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

    domain
  end
end
