class Notification < ActiveRecord::Base
  include Versions # version/notification_version.rb
  belongs_to :registrar, required: true

  before_create -> { self.read = false }

  scope :unread, -> { where(read: false) }

  validates :text, presence: true

  def mark_as_read
    self.read = true
    save
  end

  # Needed for EPP log
  def name
    "-"
  end
end
