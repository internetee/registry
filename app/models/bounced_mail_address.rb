class BouncedMailAddress < ApplicationRecord
  validates :email, presence: true

  error_storage_keys = %i[enqueued_at job_name error_description]
  store_accessor :additional_error_description, *error_storage_keys

  def bounce_reason
    "#{action} (#{status} #{diagnostic})"
  end

  def self.record(json)
    bounced_records = json['bounce']['bouncedRecipients']
    bounced_records.each do |record|
      bounce_record = BouncedMailAddress.new(params_from_json(json, record))

      bounce_record.save
    end
  end

  def self.params_from_json(json, bounced_record)
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
