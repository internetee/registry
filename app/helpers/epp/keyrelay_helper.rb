module Epp::KeyrelayHelper
  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity

  def keyrelay
    handle_errors and return unless validate_keyrelay_request

    @domain = find_domain

    handle_errors(@domain) and return unless @domain
    handle_errors(@domain) and return unless @domain.authenticate(parsed_frame.css('pw').text)
    handle_errors(@domain) and return unless @domain.keyrelay(parsed_frame, current_epp_user.registrar)

    render '/epp/shared/success'
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  private

  def validate_keyrelay_request
    epp_request_valid?('pubKey', 'flags', 'protocol', 'algorithm', 'name', 'pw')

    if parsed_frame.css('relative').text.present? && parsed_frame.css('absolute').text.present?
      epp_errors << {
        code: '2003',
        msg: I18n.t('only_one_parameter_allowed', param_1: 'relative', param_2: 'absolute')
      }
    elsif parsed_frame.css('relative').text.empty? && parsed_frame.css('absolute').text.empty?
      epp_errors << {
        code: '2003',
        msg: I18n.t('required_parameter_missing_choice', param_1: 'relative', param_2: 'absolute')
      }
    end

    epp_errors.empty?
  end

  def find_domain
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
