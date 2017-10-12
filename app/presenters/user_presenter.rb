class UserPresenter
  def initialize(user:, view:)
    @user = user
    @view = view
  end

  def login_with_role
    "#{user.login} (#{role_name}) - #{user.registrar_name}"
  end

  private

  def role_name
    user.roles.first
  end

  attr_reader :user
  attr_reader :view
end
