class BouncedMailAddress < ApplicationRecord
  validates :email, presence: true
  validates :bounce_reason, presence: true

  def diagnostic
    response_json['diagnosticCode']
  end

  def action
    response_json['action']
  end

  def status
    response_json['status']
  end

  def self.record(json)
    bounced_records = json['bounce']['bouncedRecipients']
    bounced_records.each do |record|
      bounce_record = BouncedMailAddress.new(email: record['emailAddress'], response_json: record)
      bounce_record.save
    end
  end
end
