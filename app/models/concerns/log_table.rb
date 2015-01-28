module LogTable
  extend ActiveSupport::Concern

  included do
    # one plase to define log tables
    log_table_name = "log_#{table_name.sub('_versions', '').tableize}"
    self.table_name    = log_table_name
    self.sequence_name = log_table_name
  end
end
