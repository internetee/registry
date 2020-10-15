class Registrant::SessionsController < Devise::SessionsController
  layout 'registrant/application'

  private

  def after_sign_in_path_for(_resource_or_scope)
    registrant_root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_registrant_user_session_path
  end

  def user_for_paper_trail
    current_registrant_user.present? ? current_registrant_user.id_role_username : 'anonymous'
  end
end
