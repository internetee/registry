# Sends every paid business registry invoice that is not in Directo yet, so a failed run is retried by the next one.
class DirectoReserveDomainInvoiceForwardJob < ApplicationJob
  def perform
    if Setting.directo_reservation_product_name.blank?
      Rails.logger.warn('[DIRECTO] directo_reservation_product_name is not set, reservation invoices are not sent')
      return
    end

    invoices = ReserveDomainInvoice.paid.where(in_directo: false).to_a
    return if invoices.empty?

    EisBilling::SendDataToDirecto.send_request(object_data: invoices.map(&:as_directo_json),
                                               initiator: ReserveDomainInvoice::INITIATOR)
  end
end
