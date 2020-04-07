class CopyOldHistoryJob < Que::Job
  MODELS = %w[contact
              domain
              account_activity
              account action
              bank_statement
              bank_transaction
              blocked_domain
              certificate
              dnskey
              domain_contact
              invoice
              invoice_item
              nameserver
              notification
              payment_order
              registrant_verification
              registrar
              reserved_domain
              setting
              user
              white_ip].freeze

  def run
    MODELS.each do |model|
      copy_history(model)
    end
  end

  private

  def copy_history(model)
    old_history = "#{model.capitalize}Version".constantize.all

    new_klass = "Audit::#{model.capitalize}History".constantize
    history_array = []

    old_history.find_each do |old_entry|
      process_old_history(new_klass: new_klass, old_entry: old_entry, array: history_array)
    end

    history_array.in_groups_of(100, false) do |group|
      new_klass.transaction { new_klass.import group }
    end
  end

  def process_old_history(new_klass:, old_entry:, array:)
    old_value = old_entry.object || {}
    new_value = generate_new_value(old_entry&.object_changes)
    new_value['children'] = old_entry&.children

    attrs = attrs(old_history_entry: old_entry, old_value: old_value, new_value: new_value)

    already_exist = new_klass.find_by(recorded_at: recorded_at,
                                      object_id: object_id).present?
    return if already_exist

    array << attrs
  end

  def attrs(old_history_entry:, old_value:, new_value:)
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
