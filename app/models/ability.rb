class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :show, to: :view
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
  # rubocop: disable Metrics/LineLength
  def epp
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
  # rubocop: enable Metrics/LineLength
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/PerceivedComplexity

  def registrar
    can :manage, Invoice
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
    can :manage, BankStatement
    can :manage, BankTransaction
    can :manage, Invoice
    can :read, ApiLog::EppLog
    can :read, ApiLog::ReppLog
    # can :index, :delayed_job
    can :create, :zonefile
    can :access, :settings_menu
  end
end
