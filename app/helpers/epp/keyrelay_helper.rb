module Epp::KeyrelayHelper
  def keyrelay
    domain = Domain.find_by(name: parsed_frame.css('name').text)

    abs_datetime = parsed_frame.css('absolute').text
    abs_datetime = abs_datetime.to_date if abs_datetime

    kr = domain.keyrelays.create(
      domain: domain,
      pa_date: Time.now,
      key_data_flags: parsed_frame.css('flags').text,
      key_data_protocol: parsed_frame.css('protocol').text,
      key_data_alg: parsed_frame.css('alg').text,
      key_data_public_key: parsed_frame.css('pubKey').text,
      auth_info_pw: parsed_frame.css('pw').text,
      expiry_relative: parsed_frame.css('relative').text,
      expiry_absolute: abs_datetime,
      requester: current_epp_user.registrar,
      accepter: domain.registrar
    )

    domain.registrar.messages.create(
      body: 'Key Relay action completed successfully.',
      attached_obj_type: kr.class.to_s,
      attached_obj_id: kr.id
    )

    render '/epp/shared/success'
  end
end
