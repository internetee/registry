class MailTemplate < ActiveRecord::Base
  validates :name, :subject, :from, :body, :text_body, presence: true
end
