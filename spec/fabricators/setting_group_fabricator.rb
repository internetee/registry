Fabricator(:setting_group) do
  code 'domain_validation'
  settings { [
    Fabricate(:setting, code: 'ns_min_count', value: 1),
    Fabricate(:setting, code: 'ns_max_count', value: 13)
  ]}
end

Fabricator(:domain_validation_setting_group, from: :setting_group) do
  code 'domain_validation'
  settings { [
    Fabricate(:setting, code: 'ns_min_count', value: 1),
    Fabricate(:setting, code: 'ns_max_count', value: 13)
  ]}
end
