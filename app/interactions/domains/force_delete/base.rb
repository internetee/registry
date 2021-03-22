module Domains
  module ForceDelete
    class Base < ActiveInteraction::Base
      object :domain,
             class: Domain,
             description: 'Domain to set ForceDelete on'
      symbol :type,
             default: :fast_track,
             description: 'Force delete type, might be :fast_track or :soft'
      boolean :notify_by_email,
              default: false,
              description: 'Do we need to send email notification'
      string  :reason,
              default: nil,
              description: 'Which mail template to use explicitly'
      string  :email,
              default: nil,
              description: 'Possible invalid email to notify on'

      validates :type, inclusion: { in: %i[fast_track soft] }
    end
  end
end
