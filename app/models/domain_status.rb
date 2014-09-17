class DomainStatus < ActiveRecord::Base
  include EppErrors

  belongs_to :domain

  CLIENT_DELETE_PROHIBITED = 'clientDeleteProhibited'
  SERVER_DELETE_PROHIBITED = 'serverDeleteProhibited'
  CLIENT_HOLD = 'clientHold'
  SERVER_HOLD = 'serverHold'
  CLIENT_RENEW_PROHIBITED = 'clientRenewProhibited'
  SERVER_RENEW_PROHIBITED = 'serverRenewProhibited'
  CLIENT_TRANSFER_PROHIBITED = 'clientTransferProhibited'
  SERVER_TRANSFER_PROHIBITED = 'serverTransferProhibited'
  CLIENT_UPDATE_PROHIBITED = 'clientUpdateProhibited'
  SERVER_UPDATE_PROHIBITED = 'serverUpdateProhibited'
  INACTIVE = 'inactive'
  OK = 'ok'
  PENDING_CREATE = 'pendingCreate'
  PENDING_DELETE = 'pendingDelete'
  PENDING_RENEW = 'pendingRenew'
  PENDING_TRANSFER = 'pendingTransfer'
  PENDING_UPDATE = 'pendingUpdate'

  STATUSES = [CLIENT_DELETE_PROHIBITED, SERVER_DELETE_PROHIBITED, CLIENT_HOLD, SERVER_HOLD, CLIENT_RENEW_PROHIBITED, SERVER_RENEW_PROHIBITED, CLIENT_TRANSFER_PROHIBITED, SERVER_TRANSFER_PROHIBITED, CLIENT_UPDATE_PROHIBITED, SERVER_UPDATE_PROHIBITED, INACTIVE, OK, PENDING_CREATE, PENDING_DELETE, PENDING_RENEW, PENDING_TRANSFER, PENDING_UPDATE]

  validates :value, uniqueness: { scope: :domain_id }

  def epp_code_map
    {
      '2302' => [ # Object exists
        [:value, :taken, { value: { obj: 'status', val: value } }]
      ]
    }
  end
end
