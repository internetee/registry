# Mail calls delivered_email after do_delivery succeeded; with raise_delivery_errors = true
# a failed SMTP delivery raises first, so a row means the email really went out
# (deliver_now, deliver_later and job retries alike).
class Observers::PendingNotificationObserver
  HEADER = 'X-Pending-Notification'.freeze

  def self.delivered_email(message)
    header = message.header[HEADER]
    return unless header

    domain_id, kind = header.value.split(':', 2)
    DomainPendingNotification.create!(domain_id: domain_id, kind: kind, recipients: message.to)
  end
end
