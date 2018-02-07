class EppSession < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :registrar

  validates :session_id, presence: true
end
