class PopulateDomainStatuses < ActiveRecord::Migration
  def change
    SettingGroup.create(code: 'domain_statuses', settings: [
      Setting.create(code: 'clientDeleteProhibited'.underscore, value: 'clientDeleteProhibited'),
      Setting.create(code: 'serverDeleteProhibited'.underscore, value: 'serverDeleteProhibited'),
      Setting.create(code: 'clientHold'.underscore, value: 'clientHold'),
      Setting.create(code: 'serverHold'.underscore, value: 'serverHold'),
      Setting.create(code: 'clientRenewProhibited'.underscore, value: 'clientRenewProhibited'),
      Setting.create(code: 'serverRenewProhibited'.underscore, value: 'serverRenewProhibited'),
      Setting.create(code: 'clientTransferProhibited'.underscore, value: 'clientTransferProhibited'),
      Setting.create(code: 'serverTransferProhibited'.underscore, value: 'serverTransferProhibited'),
      Setting.create(code: 'clientUpdateProhibited'.underscore, value: 'clientUpdateProhibited'),
      Setting.create(code: 'serverUpdateProhibited'.underscore, value: 'serverUpdateProhibited'),
      Setting.create(code: 'inactive', value: 'inactive'),
      Setting.create(code: 'ok', value: 'ok'),
      Setting.create(code: 'pendingCreate'.underscore, value: 'pendingCreate'),
      Setting.create(code: 'pendingDelete'.underscore, value: 'pendingDelete'),
      Setting.create(code: 'pendingRenew'.underscore, value: 'pendingRenew'),
      Setting.create(code: 'pendingTransfer'.underscore, value: 'pendingTransfer'),
      Setting.create(code: 'pendingUpdate'.underscore, value: 'pendingUpdate')
    ])
  end
end
