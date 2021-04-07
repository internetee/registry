module Domain::RegistryLockable
  extend ActiveSupport::Concern
    class Base < ActiveInteraction::Base
    object :domain,
            class: Domain,
            description: 'Domain to set ForceDelete on'
    end
  end
  