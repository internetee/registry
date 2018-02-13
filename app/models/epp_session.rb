class EppSession < ActiveRecord::Base
  belongs_to :user, required: true

  validates :session_id, uniqueness: true, presence: true
end
