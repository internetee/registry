class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    @user = user || User.new
    @user.roles.each { |role| send(role) } if @user.roles

    return if @user.roles || @user.roles.any?

    can :show, :dashboard
  end

  def user
    can :show, :dashboard
  end

  def customer_service
    user
    can :manage, Domain
    can :manage, Contact
    can :manage, Registrar
  end

  def admin
    customer_service
    can :manage, Setting
    can :manage, ZonefileSetting
    can :manage, DomainVersion
    can :manage, User
    can :manage, ApiUser
    can :manage, Keyrelay
    can :manage, LegalDocument
    can :read, ApiLog::EppLog
    can :read, ApiLog::ReppLog
    can :index, :delayed_job
    can :create, :zonefile
    can :access, :settings_menu
  end
end
