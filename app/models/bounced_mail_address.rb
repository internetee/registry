class BouncedMailAddress < ApplicationRecord
  validates :email, :message_id, :bounce_type, :bounce_subtype, :action, :status, presence: true
  before_validation :assign_bounce_reason

  def assign_bounce_reason
    return self.bounce_reason = nil unless recipient_json

    self.bounce_reason = "#{action} (#{status} #{diagnostic})"
  end

  def self.record(json)
    bounced_records = json['bounce']['bouncedRecipients']
    bounced_records.each do |record|
      bounce_record = BouncedMailAddress.new(params_from_json(json, record))

      bounce_record.save
    end
  end

  def params_from_json(json, bounced_record)
    {
      email: bounced_record['emailAddress'],
      message_id: json['mail']['messageId'],
      bounce_type: json['bounce']['bounceType'],
      bounce_subtype: json['bounce']['bounceSubType'],
      action: bounced_record['action'],
      status: bounced_record['status'],
      diagnostic: bounced_record['diagnosticCode'],
    }
  end
end
