Fabricator(:setting_group) do
  code 'domain_validation'
  settings do
    [
      Fabricate(:setting, code: 'ns_min_count', value: 1),
      Fabricate(:setting, code: 'ns_max_count', value: 13)
    ]
  end
end

Fabricator(:domain_validation_setting_group, from: :setting_group) do
  code 'domain_validation'
  settings do
    [
      Fabricate(:setting, code: 'ns_min_count', value: 1),
      Fabricate(:setting, code: 'ns_max_count', value: 13)
    ]
  end
end

Fabricator(:domain_statuses_setting_group, from: :setting_group) do
  code 'domain_statuses'
  settings do
    [
      Fabricate(:setting, code: 'client_hold', value: 'clientHold'),
      Fabricate(:setting, code: 'client_update_prohibited', value: 'clientUpdateProhibited')
    ]
  end
end
