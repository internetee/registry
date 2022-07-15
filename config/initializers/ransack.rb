Ransack.configure do |config|
  config.add_predicate 'contains_array',
                       arel_predicate: 'contains_array',
                       formatter: proc { |v| "{#{v}}" },
                       validator: proc { |v| v.present? },
                       type: :string
end