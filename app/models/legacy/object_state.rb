module Legacy
  class ObjectState < Db
    self.table_name = :object_state

    def name
      map = {
        2 => "serverRenewProhibited",
        5 => "serverOutzoneManual",
        6 => "serverInzoneManual",
        7 => "serverBlocked",
        8 => "expirationWarning",
        9 => "expired",
        10 => "unguarded",
        11 => "validationWarning1",
        12 => "validationWarning2",
        13 => "notValidated",
        14 => "nssetMissing",
        15 => "outzone",
        18 => "serverRegistrantChangeProhibited",
        19 => "deleteWarning",
        20 => "outzoneUnguarded",
        1 => "serverDeleteProhibited",
        3 => "serverTransferProhibited",
        4 => "serverUpdateProhibited",
        16 => "linked",
        17 => "deleteCandidate",
        21 => "forceDelete"
      }

      map[state_id]
    end
  end
end
