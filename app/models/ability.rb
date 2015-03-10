class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :show, :create, :update, :destroy, to: :crud

    @user = user || AdminUser.new

    case @user.class.to_s
    when 'AdminUser'
      @user.roles.each { |role| send(role) } if @user.roles
    when 'ApiUser'
      epp
    end

    can :show, :dashboard
  end

  def epp
    # Epp::Contact
    can(:info,   Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id || c.auth_info == pw }
    can(:check,  Epp::Contact)
    can(:create, Epp::Contact)
    can(:update, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id && c.auth_info == pw }
    can(:delete, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id && c.auth_info == pw }
    can(:renew,  Epp::Contact)
    can(:view_password, Epp::Contact) { |c| c.registrar_id == @user.registrar_id }

    # Epp::Domain
    can(:info, Epp::EppDomain) { |d, pw| d.registrar_id == @user.registrar_id || d.auth_info == pw }
    can(:check,  Epp::EppDomain)
    can(:create,  Epp::EppDomain)
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
    can :manage, Certificate
    can :manage, Keyrelay
    can :manage, LegalDocument
    can :read, ApiLog::EppLog
    can :read, ApiLog::ReppLog
    can :index, :delayed_job
    can :create, :zonefile
    can :access, :settings_menu
  end
end
