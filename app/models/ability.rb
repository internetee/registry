class Ability
  include CanCan::Ability

  def initialize(user)

    alias_action :create, :read, :update, :destroy, :to => :crud

    user ||= User.new
    if Rails.env.development? || Rails.env.test? || (REGISTRY_ENV == :admin && user.admin?)
      can :manage, Domain
      can :switch, :registrar
      can :crud, DomainTransfer
      can :approve_as_client, DomainTransfer, status: DomainTransfer::PENDING
    elsif user.persisted?
      can :manage, Domain, registrar_id: user.registrar.id
      can :read, DomainTransfer, transfer_to_id: user.registrar.id
      can :read, DomainTransfer, transfer_from_id: user.registrar.id
      can :approve_as_client, DomainTransfer, transfer_from_id: user.registrar.id, status: DomainTransfer::PENDING
    end
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
end
