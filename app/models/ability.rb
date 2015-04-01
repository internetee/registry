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
      registrar
    end

    can :show, :dashboard
  end

  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/PerceivedComplexity
  def epp
    # Epp::Domain
    can(:info,     Epp::Domain) { |d, pw| d.registrar_id == @user.registrar_id || d.auth_info == pw }
    can(:check,    Epp::Domain)
    can(:create,   Epp::Domain)
    can(:renew,    Epp::Domain)
    can(:update,   Epp::Domain) { |d, pw| d.registrar_id == @user.registrar_id || d.auth_info == pw }
    can(:transfer, Epp::Domain) { |d, pw| d.auth_info == pw }

    # Epp::Contact
    can(:info, Epp::Contact)           { |c, pw| c.registrar_id == @user.registrar_id || c.auth_info == pw }
    can(:view_full_info, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id || c.auth_info == pw }
    can(:check,  Epp::Contact)
    can(:create, Epp::Contact)
    can(:update, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id && c.auth_info == pw }
    can(:delete, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id && c.auth_info == pw }
    can(:renew,  Epp::Contact)
    can(:view_password, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id || c.auth_info == pw }
  end
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/PerceivedComplexity

  def registrar
    can :manage, Invoice
  end

  def user
    can :show, :dashboard
    can :manage, Invoice
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
