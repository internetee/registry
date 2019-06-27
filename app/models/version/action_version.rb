class ActionVersion < PaperTrail::Version
  self.table_name = :log_actions
  self.sequence_name = :log_actions_id_seq
end
