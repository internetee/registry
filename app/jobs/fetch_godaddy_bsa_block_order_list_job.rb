# frozen_string_literal: true

# rubocop:disable Metrics

class FetchGodaddyBsaBlockOrderListJob < ApplicationJob
  queue_as :default

  LIMIT = 20
  LIMIT_MESSAGE = 'Limit reached. No more block orders to fetch'

  def perform
    fetch_block_order_list(offset: 0)
  end

  def fetch_block_order_list(offset:)
    res = Bsa::BlockOrderListService.call(offset: offset, limit: LIMIT)
    return res.error.inspect unless res.result?
    return LIMIT_MESSAGE if res.body.total.zero? || res.body.list.blank?

    bsa_attributes = collect_bsa_values(res)
    BsaProtectedDomain.upsert_all(bsa_attributes)
    offset_limit = res.body.total / LIMIT
    return LIMIT_MESSAGE if offset >= offset_limit

    offset += 1
    fetch_block_order_list(offset: offset)
  end

  def collect_bsa_values(res)
    res.body.list.map do |block_order|
      {
        order_id: block_order['blockOrder']['blockOrderId'],
        suborder_id: block_order['blockSubOrderId'],
        domain_name: "#{block_order['label']}#{block_order['tld']['displayName']}",
        state: block_order['blockOrderStatus']['blockOrderStatusId'],
        registration_code: SecureRandom.hex,
        create_date: DateTime.parse(block_order['createdDt']),
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }
    end
  end
end
