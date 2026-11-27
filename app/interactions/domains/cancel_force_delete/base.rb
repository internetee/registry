module Domains
  module CancelForceDelete
    class Base < ActiveInteraction::Base
      object :domain,
             class: Domain,
             description: 'Domain to cancel ForceDelete on'
      string :notification_key,
             default: 'force_delete_cancelled',
             description: 'I18n key of the poll message sent to the registrar'
    end
  end
end
