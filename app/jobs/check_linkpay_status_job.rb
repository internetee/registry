class CheckLinkpayStatusJob < ApplicationJob
  retry_on(*Bundler::Fetcher::HTTP_ERRORS)

  def perform(payment_order_id)
    payment_order = PaymentOrder.find(payment_order_id)
    return unless payment_order_valid?(payment_order)

    payment_order.check_linkpay_status
  end

  def payment_order_valid?(order)
    order.present? && order.response.present?
  end
end
