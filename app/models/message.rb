class Message < ActiveRecord::Base
  belongs_to :registrar

  before_create -> { self.queued = true }

  scope :queued, -> { where(queued: true) }
end
