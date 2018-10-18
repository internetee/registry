class Notification < ActiveRecord::Base
  include Versions # version/notification_version.rb

  belongs_to :registrar
  belongs_to :action

  scope :unread, -> { where(read: false) }

  validates :text, presence: true

  after_initialize :set_defaults

  def mark_as_read
    raise 'Read notification cannot be marked as read again' if read?
    self.read = true
    save
  end

  def unread?
    !read?
  end

  # Needed for EPP log
  def name
    ''
  end

  private

  def set_defaults
    self.read = false if read.nil?
  end
end
