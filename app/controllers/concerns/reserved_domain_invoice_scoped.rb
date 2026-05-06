module ReservedDomainInvoiceScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_reserved_domain_invoice
  end

  private

  def set_reserved_domain_invoice
    @reserved_domain_invoice = ReserveDomainInvoice.find_by(
      invoice_number: params[:invoice_number],
      metainfo: params[:user_unique_id]
    )
    raise ActiveRecord::RecordNotFound, 'Reserved domain invoice not found' if @reserved_domain_invoice.nil?
  end
end
