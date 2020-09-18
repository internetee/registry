class BouncedMailAddress < ApplicationRecord
  validates :email, presence: true
  validates :bounce_reason, :recipient_json, :response_json, presence: true
  before_validation :assign_bounce_reason

  def assign_bounce_reason
    if recipient_json
      self.bounce_reason = "#{action} (#{status} #{diagnostic})"
    else
      self.bounce_reason = nil
    end
  end

  def diagnostic
    return nil unless recipient_json
    recipient_json['diagnosticCode']
  end

  def action
    return nil unless recipient_json
    recipient_json['action']
  end

  def status
    return nil unless recipient_json
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
