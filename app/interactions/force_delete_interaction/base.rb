module ForceDeleteInteraction
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

    validates :type, inclusion: { in: %i[fast_track soft] }
  end
end

