class ContactStatus < ActiveRecord::Base
  include Versions # version/contact_status_version.rb
  include EppErrors

  belongs_to :contact

  # Requests to delete the object MUST be rejected.
  CLIENT_DELETE_PROHIBITED = 'clientDeleteProhibited'
  SERVER_DELETE_PROHIBITED = 'serverDeleteProhibited'

  # Requests to transfer the object MUST be rejected.
  CLIENT_TRANSFER_PROHIBITED = 'clientTransferProhibited'
  SERVER_TRANSFER_PROHIBITED = 'serverTransferProhibited'

  # The contact object has at least one active association with
  # another object, such as a domain object. Servers SHOULD provide
  # services to determine existing object associations.
  # "linked" status MAY be combined with any status.
  LINKED = 'linked'

  # This is the normal status value for an object that has no pending
  # operations or prohibitions. This value is set and removed by the
  # server as other status values are added or removed.
  # "ok" status MAY only be combined with "linked" status.
  OK = 'ok'

  # Requests to update the object (other than to remove this status) MUST be rejected.
  CLIENT_UPDATE_PROHIBITED = 'clientUpdateProhibited'
  SERVER_UPDATE_PROHIBITED = 'serverUpdateProhibited'

  # A transform command has been processed for the object, but the
  # action has not been completed by the server. Server operators can
  # delay action completion for a variety of reasons, such as to allow
  # for human review or third-party action. A transform command that
  # is processed, but whose requested action is pending, is noted with
  # response code 1001.
  # When the requested action has been completed, the pendingCreate,
  # pendingDelete, pendingTransfer, or pendingUpdate status value MUST be
  # removed.  All clients involved in the transaction MUST be notified
  # using a service message that the action has been completed and that
  # the status of the object has changed.
  # The pendingCreate, pendingDelete, pendingTransfer, and pendingUpdate
  # status values MUST NOT be combined with each other.
  PENDING_CREATE = 'pendingCreate'
  # "pendingTransfer" status MUST NOT be combined with either
  # "clientTransferProhibited" or "serverTransferProhibited" status.
  PENDING_TRANSFER = 'pendingTransfer'
  # "pendingUpdate" status MUST NOT be combined with either
  # "clientUpdateProhibited" or "serverUpdateProhibited" status.
  PENDING_UPDATE = 'pendingUpdate'
  # "pendingDelete" MUST NOT be combined with either 
  # "clientDeleteProhibited" or "serverDeleteProhibited" status.
  PENDING_DELETE = 'pendingDelete' 

  STATUSES = [
    CLIENT_DELETE_PROHIBITED, SERVER_DELETE_PROHIBITED, 
    CLIENT_TRANSFER_PROHIBITED,
    SERVER_TRANSFER_PROHIBITED, CLIENT_UPDATE_PROHIBITED, SERVER_UPDATE_PROHIBITED,
    OK, PENDING_CREATE, PENDING_DELETE, PENDING_TRANSFER,
    PENDING_UPDATE, LINKED
  ]

  CLIENT_STATUSES = [
    CLIENT_DELETE_PROHIBITED, CLIENT_TRANSFER_PROHIBITED,
    CLIENT_UPDATE_PROHIBITED
  ]

  SERVER_STATUSES = [
    SERVER_DELETE_PROHIBITED, SERVER_TRANSFER_PROHIBITED,
    SERVER_UPDATE_PROHIBITED 
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
