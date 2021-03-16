class BouncedMailAddress < ApplicationRecord
  validates :email, :message_id, :bounce_type, :bounce_subtype, :action, :status, presence: true
  after_destroy :destroy_aws_suppression
  after_create :force_delete_from_bounce

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

  def destroy_aws_suppression
    return unless BouncedMailAddress.ses_configured?

    res = Aws::SESV2::Client.new.delete_suppressed_destination(email_address: email)
    res.successful?
  rescue Aws::SESV2::Errors::ServiceError => e
    logger.warn("Suppression not removed. #{e}")
  end

  def self.ses_configured?
    ses ||= Aws::SESV2::Client.new
    ses.config.credentials.access_key_id.present?
  rescue Aws::Errors::MissingRegionError
    false
  end

  def force_delete_from_bounce
    Domains::ForceDeleteBounce::Base.run(bounced_mail_address: self)
  end
end
