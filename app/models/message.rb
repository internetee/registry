class Message < ActiveRecord::Base
  include Versions # version/message_version.rb
  belongs_to :registrar, required: true

  before_create -> { self.queued = true }

  scope :queued, -> { where(queued: true) }

  validates :body, presence: true

  def dequeue
    self.queued = false
    save
  end

  def name
    "-"
  end
end
