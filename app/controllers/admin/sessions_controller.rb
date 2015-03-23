class Admin::SessionsController < SessionsController
  layout 'login'

  def create
    super
  end

  def login
  end

  def find_user_by_idc(idc)
    AdminUser.find_by(identity_code: idc)
  end
end
