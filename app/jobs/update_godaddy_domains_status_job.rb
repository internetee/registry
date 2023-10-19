# frozen_string_literal: true

class UpdateGodaddyDomainsStatusJob < ApplicationJob
  queue_as :default

  def perform(query_state, updated_state)
    BsaProtectedDomain.where(state: query_state).in_batches(of: 30) do |bsa_protected_domains|
      process(suborders_block: bsa_protected_domains, state: updated_state)
    end
  end

  private

  def process(suborders_block:, state:)
    payload = serialize_suborders_block(suborders_block: suborders_block, state: state)

    result = Bsa::BlockOrderStatusSettingService.call(payload: payload)
    return { message: result.error.message, description: result.error.description } unless result.result?

    refresh_statuses(suborders_block: suborders_block, state: state)

    result.body
  end

  def serialize_suborders_block(suborders_block:, state:)
    suborders_block.map do |suborder_block|
      { blockSubOrderId: suborder_block.suborder_id, status: BsaProtectedDomain.states.key(state) }
    end
  end

  def refresh_statuses(suborders_block:, state:)
    suborders_block.update_all(state: state)
  end
end
