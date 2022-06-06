class Notification < ApplicationRecord
  include Versions # version/notification_version.rb
  include EppErrors

  belongs_to :registrar
  belongs_to :action, optional: true

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

  def registry_lock?
    text.include?('has been locked') || text.include?('has been unlocked')
  end

  private

  def set_defaults
    self.read = false if read.nil?
  end
end
