class BouncedMailAddress < ApplicationRecord
  validates :email, presence: true
  validates :bounce_reason, :recipient_json, :response_json, presence: true
  before_validation :assign_bounce_reason

  def assign_bounce_reason
    return self.bounce_reason = nil unless recipient_json

    self.bounce_reason = "#{action} (#{status} #{diagnostic})"
  end

  def diagnostic
    return unless recipient_json

    recipient_json['diagnosticCode']
  end

  def action
    return unless recipient_json

    recipient_json['action']
  end

  def status
    return unless recipient_json

    recipient_json['status']
  end

  def self.record(json)
    bounced_records = json['bounce']['bouncedRecipients']
    bounced_records.each do |record|
      bounce_record = BouncedMailAddress.new(email: record['emailAddress'], recipient_json: record,
                                             response_json: json)

      bounce_record.save
    end
  end
end
