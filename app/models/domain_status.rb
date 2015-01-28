class DomainStatus < ActiveRecord::Base
  include Versions # version/domain_status_version.rb
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

  SERVER_MANUAL_INZONE = 'serverManualInzone'
  SERVER_REGISTRANT_CHANGE_PROHIBITED = 'serverRegistrantChangeProhibited'
  SERVER_ADMIN_CHANGE_PROHIBITED = 'serverAdminChangeProhibited'
  SERVER_TECH_CHANGE_PROHIBITED = 'serverTechChangeProhibited'
  FORCE_DELETE = 'forceDelete'
  DELETE_CANDIDATE = 'deleteCandidate'
  EXPIRED = 'expired'

  STATUSES = [
    CLIENT_DELETE_PROHIBITED, SERVER_DELETE_PROHIBITED, CLIENT_HOLD, SERVER_HOLD, 
    CLIENT_RENEW_PROHIBITED, SERVER_RENEW_PROHIBITED, CLIENT_TRANSFER_PROHIBITED, 
    SERVER_TRANSFER_PROHIBITED, CLIENT_UPDATE_PROHIBITED, SERVER_UPDATE_PROHIBITED, 
    INACTIVE, OK, PENDING_CREATE, PENDING_DELETE, PENDING_RENEW, PENDING_TRANSFER, 
    PENDING_UPDATE, SERVER_MANUAL_INZONE, SERVER_REGISTRANT_CHANGE_PROHIBITED, 
    SERVER_ADMIN_CHANGE_PROHIBITED, SERVER_TECH_CHANGE_PROHIBITED, FORCE_DELETE, 
    DELETE_CANDIDATE, EXPIRED
  ]
 
  CLIENT_STATUSES = [
    CLIENT_DELETE_PROHIBITED, CLIENT_HOLD, CLIENT_RENEW_PROHIBITED, CLIENT_TRANSFER_PROHIBITED, 
    CLIENT_UPDATE_PROHIBITED
  ]
 
  SERVER_STATUSES = [
    SERVER_DELETE_PROHIBITED, SERVER_HOLD, SERVER_RENEW_PROHIBITED, SERVER_TRANSFER_PROHIBITED,
    SERVER_UPDATE_PROHIBITED, SERVER_MANUAL_INZONE, SERVER_REGISTRANT_CHANGE_PROHIBITED, 
    SERVER_ADMIN_CHANGE_PROHIBITED, SERVER_TECH_CHANGE_PROHIBITED
  ]

  def epp_code_map
    {
      '2302' => [ # Object exists
        [:value, :taken, { value: { obj: 'status', val: value } }]
      ]
    }
  end

  def server_status?
    SERVER_STATUSES.include?(value)
  end

  def client_status?
    CLIENT_STATUSES.include?(value)
  end

  class << self
    def statuses_for_client
      CLIENT_STATUSES.map { |x| x.sub('client', '') }
    end

    def statuses_for_admin
      SERVER_STATUSES.map { |x| x.sub('server', '') }
    end
  end
end
