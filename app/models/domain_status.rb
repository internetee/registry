class DomainStatus < ActiveRecord::Base
  include Versions # version/domain_status_version.rb
  include EppErrors

  belongs_to :domain

  # Requests to delete the object MUST be rejected.
  CLIENT_DELETE_PROHIBITED = 'clientDeleteProhibited'.freeze
  SERVER_DELETE_PROHIBITED = 'serverDeleteProhibited'.freeze

  # DNS delegation information MUST NOT be published for the object.
  CLIENT_HOLD = 'clientHold'.freeze
  SERVER_HOLD = 'serverHold'.freeze

  # Requests to renew the object MUST be rejected.
  CLIENT_RENEW_PROHIBITED = 'clientRenewProhibited'.freeze
  SERVER_RENEW_PROHIBITED = 'serverRenewProhibited'.freeze

  # Requests to transfer the object MUST be rejected.
  CLIENT_TRANSFER_PROHIBITED = 'clientTransferProhibited'.freeze
  SERVER_TRANSFER_PROHIBITED = 'serverTransferProhibited'.freeze

  # Requests to update the object (other than to remove this status) MUST be rejected.
  CLIENT_UPDATE_PROHIBITED = 'clientUpdateProhibited'.freeze
  SERVER_UPDATE_PROHIBITED = 'serverUpdateProhibited'.freeze

  # Delegation information has not been associated with the object.
  # This is the default status when a domain object is first created
  # and there are no associated host objects for the DNS delegation.
  # This status can also be set by the server when all host-object
  # associations are removed.
  INACTIVE = 'inactive'.freeze

  # This is the normal status value for an object that has no pending
  # operations or prohibitions.  This value is set and removed by the
  # server as other status values are added or removed.
  # "ok" status MUST NOT be combined with any other status.
  OK = 'ok'.freeze

  # A transform command has been processed for the object, but the
  # action has not been completed by the server.  Server operators can
  # delay action completion for a variety of reasons, such as to allow
  # for human review or third-party action.  A transform command that
  # is processed, but whose requested action is pending, is noted with
  # response code 1001.
  # When the requested action has been completed, the pendingCreate,
  # pendingDelete, pendingRenew, pendingTransfer, or pendingUpdate status
  # value MUST be removed.  All clients involved in the transaction MUST
  # be notified using a service message that the action has been
  # completed and that the status of the object has changed.
  # The pendingCreate, pendingDelete, pendingRenew, pendingTransfer, and
  # pendingUpdate status values MUST NOT be combined with each other.
  PENDING_CREATE = 'pendingCreate'.freeze
  # "pendingDelete" status MUST NOT be combined with either
  # "clientDeleteProhibited" or "serverDeleteProhibited" status.
  PENDING_DELETE = 'pendingDelete'.freeze
  # "pendingRenew" status MUST NOT be combined with either
  # "clientRenewProhibited" or "serverRenewProhibited" status.
  PENDING_RENEW = 'pendingRenew'.freeze
  # "pendingTransfer" status MUST NOT be combined with either
  # "clientTransferProhibited" or "serverTransferProhibited" status.
  PENDING_TRANSFER = 'pendingTransfer'.freeze
  # "pendingUpdate" status MUST NOT be combined with either
  # "clientUpdateProhibited" or "serverUpdateProhibited" status.
  PENDING_UPDATE = 'pendingUpdate'.freeze

  SERVER_MANUAL_INZONE = 'serverManualInzone'.freeze
  SERVER_REGISTRANT_CHANGE_PROHIBITED = 'serverRegistrantChangeProhibited'.freeze
  SERVER_ADMIN_CHANGE_PROHIBITED = 'serverAdminChangeProhibited'.freeze
  SERVER_TECH_CHANGE_PROHIBITED = 'serverTechChangeProhibited'.freeze
  PENDING_DELETE_CONFIRMATION = 'pendingDeleteConfirmation'.freeze
  FORCE_DELETE = 'serverForceDelete'.freeze
  DELETE_CANDIDATE = 'deleteCandidate'.freeze
  EXPIRED = 'expired'.freeze

  STATUSES = [
    CLIENT_DELETE_PROHIBITED, SERVER_DELETE_PROHIBITED, CLIENT_HOLD, SERVER_HOLD,
    CLIENT_RENEW_PROHIBITED, SERVER_RENEW_PROHIBITED, CLIENT_TRANSFER_PROHIBITED,
    SERVER_TRANSFER_PROHIBITED, CLIENT_UPDATE_PROHIBITED, SERVER_UPDATE_PROHIBITED,
    INACTIVE, OK, PENDING_CREATE, PENDING_DELETE, PENDING_DELETE_CONFIRMATION, PENDING_RENEW, PENDING_TRANSFER,
    PENDING_UPDATE, SERVER_MANUAL_INZONE, SERVER_REGISTRANT_CHANGE_PROHIBITED,
    SERVER_ADMIN_CHANGE_PROHIBITED, SERVER_TECH_CHANGE_PROHIBITED, FORCE_DELETE,
    DELETE_CANDIDATE, EXPIRED
  ].freeze

  CLIENT_STATUSES = [
    CLIENT_DELETE_PROHIBITED, CLIENT_HOLD, CLIENT_RENEW_PROHIBITED, CLIENT_TRANSFER_PROHIBITED,
    CLIENT_UPDATE_PROHIBITED
  ].freeze

  SERVER_STATUSES = [
    SERVER_DELETE_PROHIBITED, SERVER_HOLD, SERVER_RENEW_PROHIBITED, SERVER_TRANSFER_PROHIBITED,
    SERVER_UPDATE_PROHIBITED, SERVER_MANUAL_INZONE, SERVER_REGISTRANT_CHANGE_PROHIBITED,
    SERVER_ADMIN_CHANGE_PROHIBITED, SERVER_TECH_CHANGE_PROHIBITED
  ].freeze

  UPDATE_PROHIBIT_STATES = [
    DomainStatus::PENDING_DELETE_CONFIRMATION,
    DomainStatus::CLIENT_UPDATE_PROHIBITED,
    DomainStatus::SERVER_UPDATE_PROHIBITED,
    DomainStatus::PENDING_CREATE,
    DomainStatus::PENDING_UPDATE,
    DomainStatus::PENDING_DELETE,
    DomainStatus::PENDING_RENEW,
    DomainStatus::PENDING_TRANSFER,
  ].freeze

  DELETE_PROHIBIT_STATES = [
    DomainStatus::CLIENT_DELETE_PROHIBITED,
    DomainStatus::SERVER_DELETE_PROHIBITED,
    DomainStatus::CLIENT_UPDATE_PROHIBITED,
    DomainStatus::SERVER_UPDATE_PROHIBITED,
    DomainStatus::PENDING_CREATE,
    DomainStatus::PENDING_RENEW,
    DomainStatus::PENDING_TRANSFER,
    DomainStatus::PENDING_UPDATE,
    DomainStatus::PENDING_DELETE,
  ].freeze

  def epp_code_map
    {
      '2302' => [ # Object exists
        [:value, :taken, { value: { obj: 'status', val: value } }],
      ],
    }
  end

  def server_status?
    SERVER_STATUSES.include?(value)
  end

  def client_status?
    CLIENT_STATUSES.include?(value)
  end

  def human_value
    case value
    when 'ok'
      'ok (paid and in zone)'
    else
      value
    end
  end

  class << self
    def admin_statuses
      admin_statuses_map.map(&:second)
    end

    def admin_statuses_map
      [
        ['Hold', SERVER_HOLD],
        ['ManualInzone', SERVER_MANUAL_INZONE],
        ['RenewProhibited', SERVER_RENEW_PROHIBITED],
        ['TransferProhibited', SERVER_TRANSFER_PROHIBITED],
        ['RegistrantChangeProhibited', SERVER_REGISTRANT_CHANGE_PROHIBITED],
        ['AdminChangeProhibited', SERVER_ADMIN_CHANGE_PROHIBITED],
        ['TechChangeProhibited', SERVER_TECH_CHANGE_PROHIBITED],
        ['UpdateProhibited', SERVER_UPDATE_PROHIBITED],
        ['DeleteProhibited', SERVER_DELETE_PROHIBITED],
      ]
    end

    def admin_not_deletable_statuses
      [
        OK,
        INACTIVE,
        FORCE_DELETE,
        PENDING_CREATE,
        PENDING_RENEW,
        PENDING_TRANSFER,
        PENDING_UPDATE,
        PENDING_DELETE_CONFIRMATION,
        DELETE_CANDIDATE,
      ]
    end
  end
end
