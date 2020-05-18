class CopyOldHistoryJob < Que::Job
  MODELS = %w[AccountActivity
              Account
              Action
              BankStatement
              BankTransaction
              BlockedDomain
              Certificate
              Dnskey
              DomainContact
              Invoice
              InvoiceItem
              Nameserver
              Notification
              PaymentOrder
              RegistrantVerification
              Registrar
              ReservedDomain
              Setting
              User
              WhiteIp
              Contact
              Domain].freeze

  def run
    MODELS.each do |model|
      copy_history(model)
    end
  end

  def default_resolve_action
    destroy
  end

  private

  def copy_history(model)
    old_history = "#{model}Version".constantize.all
    logger = Rails.logger
    logger.info "Starting process #{model}Version"

    new_klass = "Audit::#{model}History".constantize
    current = 0
    max = old_history.count
    if max <= new_klass.all.count
      logger.info "#{model}Version already copied"
      return
    end

    old_history.find_in_batches(batch_size: 1000) do |group|
      history_array = []
      current += group.count
      group.each do |old_entry|
        process_old_history(new_klass: new_klass, old_entry: old_entry, array: history_array)
      end

      new_klass.transaction { new_klass.import history_array }

      logger.info "Processed #{current} of #{max} #{model}Version"
    end

    logger.info "Finished processing #{model}Version, collecting the garbage"
    GC.start
  end

  def process_old_history(new_klass:, old_entry:, array:)
    return unless old_entry

    old_value = old_entry.object || {}
    new_value = generate_new_value(old_entry&.object_changes)
    new_value['children'] = generate_new_value_children(old_entry)
    attrs = attrs(old_history_entry: old_entry, old_value: old_value, new_value: new_value)

    return if attrs.blank?

    already_exist = new_klass.find_by(recorded_at: old_entry.created_at,
                                      object_id: old_entry.item_id).present?
    return if already_exist

    array << attrs
  end

  def attrs(old_history_entry: nil, old_value: nil, new_value: nil)
    return {} if old_history_entry.blank?

    { object_id: old_history_entry.item_id,
      action: generate_action(old_history_entry.event),
      recorded_at: old_history_entry.created_at,
      old_value: old_value,
      new_value: new_value }
  end

  def generate_new_value(object_changes)
    hash = {}
    return hash unless object_changes

    object_changes.each do |key, value|
      hash[key] = value[1]
    end
    hash
  end

  def generate_new_value_children(old_entry)
    hash = {}
    hash = old_entry&.children if old_entry.respond_to?(:children)
    if old_entry.event == 'create' && old_entry.item_type == 'Domain'
      registrant_id = old_entry.object_changes['registrant_id'][1]
      hash[:registrant_initial] = initial_contact_versions(ids: [registrant_id],
                                                           version_date: old_entry.created_at)

      admin_contact_ids = old_entry.children['admin_contacts']
      hash[:admin_contacts_initial] = initial_contact_versions(ids: admin_contact_ids,
                                                               version_date: old_entry.created_at)

      tech_contact_ids = old_entry.children['tech_contacts']
      hash[:tech_contacts_initial] = initial_contact_versions(ids: tech_contact_ids,
                                                              version_date: old_entry.created_at)
    end
    hash
  end

  def initial_contact_versions(ids:, version_date:)
    Contact.where(id: ids).map { |contact| contact.paper_trail.version_at(version_date) }
  end

  def generate_action(event)
    case event
    when 'create'
      'INSERT'
    when 'update'
      'UPDATE'
    else
      'DELETE'
    end
  end
end
