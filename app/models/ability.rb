class Ability
  include CanCan::Ability
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/LineLength
  def initialize(user)
    alias_action :show, to: :view
    alias_action :show, :create, :update, :destroy, to: :crud

    @user = user || AdminUser.new

    case @user.class.to_s
    when 'AdminUser'
      @user.roles.each { |role| send(role) } if @user.roles
    when 'ApiUser'
      @user.roles.each { |role| send(role) } if @user.roles
      static_epp
      static_registrar
    when 'RegistrantUser'
      static_registrant
    end

    # Public user
    can :show, :dashboard
    can :create, :registrant_domain_update_confirm
  end

  def static_epp
    # Epp::Domain
    can(:info,     Epp::Domain) { |d, pw| d.registrar_id == @user.registrar_id || pw.blank? ? true : d.auth_info == pw }
    can(:check,    Epp::Domain)
    can(:create,   Epp::Domain)
    can(:renew,    Epp::Domain)
    can(:update,   Epp::Domain) { |d, pw| d.registrar_id == @user.registrar_id || d.auth_info == pw }
    can(:transfer, Epp::Domain) { |d, pw| d.auth_info == pw }
    can(:view_password, Epp::Domain) { |d, pw| d.registrar_id == @user.registrar_id || d.auth_info == pw }
    can(:delete,   Epp::Domain) { |d, pw| d.registrar_id == @user.registrar_id || d.auth_info == pw }

    # Epp::Contact
    can(:info, Epp::Contact)           { |c, pw| c.registrar_id == @user.registrar_id || pw.blank? ? true : c.auth_info == pw }
    can(:view_full_info, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id || c.auth_info == pw }
    can(:check,  Epp::Contact)
    can(:create, Epp::Contact)
    can(:update, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id || c.auth_info == pw }
    can(:delete, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id || c.auth_info == pw }
    can(:renew,  Epp::Contact)
    can(:view_password, Epp::Contact) { |c, pw| c.registrar_id == @user.registrar_id || c.auth_info == pw }
  end

  def static_registrar
    can :read, AccountActivity
    can :manage, Nameserver
    can :view, :registrar_dashboard
    can :delete, :registrar_poll
    can :manage, :registrar_xml_console
    can :manage, Depp::Contact
    can :manage, Depp::Domain
    can :renew,  Depp::Domain
    can :transfer, Depp::Domain
    can :manage, Depp::Keyrelay
    can :confirm, :keyrelay
    can :confirm, :transfer
    can :manage, :deposit
  end

  def static_registrant
    can :manage, :registrant_whois
    can :manage, Depp::Domain
  end

  def static_billing
    can :manage, Invoice
  end

  def user
    can :show, :dashboard
  end

  # api_user dynamic role
  def super
    static_epp
    static_registrar
  end

  # api_user dynamic role
  def epp
    static_epp
    static_registrar
  end

  # api_user dynamic role
  def billing
    static_registrar
    static_billing
  end

  # admin dynamic role
  def customer_service
    user
    can :manage, Domain
    can :manage, Contact
    can :manage, Registrar
  end

  # admin dynamic role
  def admin
    customer_service
    can :manage, Setting
    can :manage, ZonefileSetting
    can :manage, DomainVersion
    can :manage, User
    can :manage, ApiUser
    can :manage, AdminUser
    can :manage, Certificate
    can :manage, Keyrelay
    can :manage, LegalDocument
    can :manage, BankStatement
    can :manage, BankTransaction
    can :manage, Invoice
    can :manage, WhiteIp
    can :read, ApiLog::EppLog
    can :read, ApiLog::ReppLog
    # can :index, :delayed_job
    can :create, :zonefile
    can :access, :settings_menu
  end
  # rubocop: enable Metrics/LineLength
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/PerceivedComplexity
end
