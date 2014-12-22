class Ability
  include CanCan::Ability

  # rubocop: disable Metrics/MethodLength
  # rubocop: disable Metrics/CyclomaticComplexity
  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    user ||= User.new

    admin_role = (user.role.try(:code) == 'admin')
    user_role = (user.role.try(:code) == 'user')
    customer_service_role = (user.role.try(:code) == 'customer_service')
    no_role = user.role.nil?

    if admin_role
      can :manage, Domain
      can :manage, Contact
      can :manage, Registrar
      can :manage, Setting
      can :manage, ZonefileSetting
      can :manage, DomainVersion
      can :manage, User
      can :manage, EppUser
      can :manage, Keyrelay
      can :index, :delayed_job
      can :create, :zonefile
      can :access, :settings_menu
    elsif customer_service_role
      can :manage, Domain
      can :manage, Contact
      can :manage, Registrar
    elsif user_role
    elsif no_role
      can :show, :dashboard
    end

    can :show, :dashboard if user.persisted?

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
  # rubocop: enable Metrics/MethodLength
  # rubocop: enable Metrics/CyclomaticComplexity
end
