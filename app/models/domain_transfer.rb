class DomainTransfer < ActiveRecord::Base
  belongs_to :domain

  belongs_to :old_registrar, class_name: 'Registrar'
  belongs_to :new_registrar, class_name: 'Registrar'

  PENDING = 'pending'
  CLIENT_APPROVED = 'clientApproved'
  CLIENT_REJECTED = 'clientRejected'
  SERVER_APPROVED = 'serverApproved'

  before_create :set_wait_until

  class << self
    def request(domain, new_registrar)
      domain_transfer = create!(
        transfer_requested_at: Time.zone.now,
        domain: domain,
        old_registrar: domain.registrar,
        new_registrar: new_registrar
      )

      domain_transfer.approve if approve_automatically?
    end

    private

    def approve_automatically?
      Setting.transfer_wait_time.zero?
    end
  end

  def set_wait_until
    wait_time = Setting.transfer_wait_time
    return if wait_time == 0
    self.wait_until = transfer_requested_at + wait_time.hours
  end

  before_create :set_status

  def set_status
    if Setting.transfer_wait_time > 0
      self.status = PENDING unless status
    else
      self.status = SERVER_APPROVED unless status
      self.transferred_at = Time.zone.now unless transferred_at
    end
  end

  delegate :name, :valid_to, to: :domain, prefix: true

  def approved?
    status == CLIENT_APPROVED || status == SERVER_APPROVED
  end

  def pending?
    status == PENDING
  end

  def approve
    transaction do
      self.status = SERVER_APPROVED
      save!

      notify_old_registrar
      domain.transfer(new_registrar)
    end
  end

  private

  def notify_old_registrar
    old_contacts_codes = domain.contacts.pluck(:code).sort.uniq.join(', ')
    old_registrant_code = domain.registrant.code

    old_registrar.messages.create!(
      body: I18n.t('messages.texts.domain_transfer',
                   domain_name: domain.name,
                   old_contacts_codes: old_contacts_codes,
                   old_registrant_code: old_registrant_code),
      attached_obj_id: id,
      attached_obj_type: self.class.name
    )
  end
end
