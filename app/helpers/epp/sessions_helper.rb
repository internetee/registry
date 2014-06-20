module Epp::SessionsHelper
  def login_params
    login_params = parsed_frame.css('epp command login')
    { username: login_params.css('clID').text, password: login_params.css('pw').text }
  end
end
