module Domain::BulkUpdatable
  extend ActiveSupport::Concern

  def bulk_update_prohibited?
    discarded? || statuses_blocks_update?
  end

  def statuses_blocks_update?
    prohibited_array = [DomainStatus::SERVER_UPDATE_PROHIBITED,
                        DomainStatus::CLIENT_UPDATE_PROHIBITED]
    prohibited_array.any? { |block_status| statuses.include?(block_status) }
  end
end
