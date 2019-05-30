module Legacy
  class ObjectState < Db
    self.table_name = :object_state

    # legacy values. Just for log
    # 2 => "serverRenewProhibited",
    # 5 => "serverOutzoneManual",
    # 6 => "serverInzoneManual",
    # 7 => "serverBlocked",
    # 8 => "expirationWarning",
    # 9 => "expired",
    # 10 => "unguarded",
    # 11 => "validationWarning1",
    # 12 => "validationWarning2",
    # 13 => "notValidated",
    # 14 => "nssetMissing",
    # 15 => "outzone",
    # 18 => "serverRegistrantChangeProhibited",
    # 19 => "deleteWarning",
    # 20 => "outzoneUnguarded",
    # 1 => "serverDeleteProhibited",
    # 3 => "serverTransferProhibited",
    # 4 => "serverUpdateProhibited",
    # 16 => "linked",
    # 17 => "deleteCandidate",
    # 21 => "forceDelete"

    # new values
    STATE_NAMES = {
      2 => 'serverRenewProhibited',
      5 => 'serverHold',
      6 => 'serverManualInzone',
      # 7 => "serverBlocked",
      9 => 'expired',
      # 11 => "validationWarning1",
      # 13 => "notValidated",
      14 => 'inactive',
      15 => 'serverHold',
      18 => 'serverRegistrantChangeProhibited',
      1 => 'serverDeleteProhibited',
      3 => 'serverTransferProhibited',
      4 => 'serverUpdateProhibited',
      16 => 'linked',
      17 => 'deleteCandidate', # grupistaatus
      21 => 'serverForceDelete', # grupistaatus
    }.freeze

    def name
      STATE_NAMES[state_id]
    end

    def desc
      map = {
        1 => 'Delete prohibited',
        2 => 'Registration renew prohibited',
        3 => 'Sponsoring registrar change prohibited',
        4 => 'Update prohibited',
        7 => 'Domain blocked',
        8 => 'Expires within 30 days',
        9 => 'Expired',
        10 => 'Domain is 30 days after expiration',
        11 => 'Validation of domain expire in 30 days',
        12 => 'Validation of domain expire in 15 days',
        13 => 'Domain not validated',
        14 => 'Domain has not associated nsset',
        15 => 'Domain is not generated into zone',
        16 => 'Has relation to other records in registry',
        17 => 'Object is going to be deleted',
        18 => 'Registrant change prohibited',
        19 => 'Domain will be deleted in 11 days',
        20 => 'Domain is out of zone after 30 days from expiration',
        21 => 'Domain is forced to delete',
        5 => 'Domain is administratively kept out of zone',
        6 => 'Domain is administratively kept in zone',
      }

      map[state_id]
    end
  end
end
