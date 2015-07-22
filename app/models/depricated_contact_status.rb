class DepricatedContactStatus < ActiveRecord::Base
  self.table_name    = :contact_statuses
  self.sequence_name = :contact_statuses_id_seq
  belongs_to :contact
end
