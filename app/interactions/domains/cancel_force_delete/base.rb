module Domains
  module CancelForceDelete
    class Base < ActiveInteraction::Base
      object :domain,
             class: Domain,
             description: 'Domain to cancel ForceDelete on'
    end
  end
end
