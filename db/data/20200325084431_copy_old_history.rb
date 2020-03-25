class CopyOldHistory < ActiveRecord::Migration[5.1]
  def up
    models = %w[contact domain]
    models.each do |model|
      copy_history(model)
    end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end

  def copy_history(model)
    old_history = "#{model.capitalize}Version".constantize.all
    count, current = old_history.count, 1
    puts "Proceeding #{count} entries of #{model.capitalize}Version"

    new_history_class = "Audit::#{model.capitalize}".constantize
    history_array = []

    old_history.find_each do |old_history_entry|
      puts "Proceeding #{current} #{model.capitalize}Version of #{count}"
      process_old_history(new_history_class: new_history_class,
                          old_history_entry: old_history_entry,
                          history_array: history_array)
      current += 1
    end

    history_array.in_groups_of(100, false) do |group|
      new_history_class.import group
    end
  end

  private

  def process_old_history(new_history_class:, old_history_entry:, history_array:)
    old_value = old_history_entry.object || {}
    new_value = generate_new_value(old_history_entry&.object_changes) || {}
    new_value['children'] = old_history_entry&.children
    object_id = old_history_entry.item_id
    action = generate_action(old_history_entry.event)
    recorded_at = old_history_entry.created_at

    attrs = { object_id: object_id, action: action, recorded_at: recorded_at, old_value: old_value,
              new_value: new_value }

    already_exist = new_history_class.find_by(recorded_at: recorded_at,
                                              object_id: object_id).present?

    if already_exist
      puts "Already exists #{new_history_class} with object_id: #{object_id} "\
           "and recorded_at: #{recorded_at}"
    else
      history_array << attrs
    end
  end

  def generate_new_value(object_changes)
    hash = {}
    return unless object_changes

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
