module Serializers
  module Repp
    class Invoice
      attr_reader :invoice

      def initialize(invoice, simplify: false)
        @invoice = invoice
        @simplify = simplify
      end

      def to_json(obj = invoice)
        return simple_object if @simplify

        {
          id: obj.id, issue_date: obj.issue_date, cancelled_at: obj.cancelled_at,
          paid: obj.paid?, payable: obj.payable?, cancellable: invoice.cancellable?,
          receipt_date: obj.receipt_date, payment_link: obj.payment_link,
          number: obj.number, subtotal: obj.subtotal, vat_amount: obj.vat_amount,
          vat_rate: obj.vat_rate, total: obj.total,
          description: obj.description, reference_no: obj.reference_no,
          created_at: obj.created_at, updated_at: obj.updated_at,
          due_date: obj.due_date, currency: obj.currency,
          seller: seller, buyer: buyer, items: items,
          recipient: obj.buyer.billing_email
        }
      end

      private

      def seller
        {
          name: invoice.seller_name,
          reg_no: invoice.seller_reg_no,
          iban: invoice.seller_iban,
          bank: invoice.seller_bank,
          swift: invoice.seller_swift,
          vat_no: invoice.seller_vat_no,
          address: invoice.seller_address,
          country: invoice.seller_country.name,
          phone: invoice.seller_phone,
          url: invoice.seller_url,
          email: invoice.seller_email,
          contact_name: invoice.seller_contact_name,
        }
      end

      def buyer
        {
          name: invoice.buyer_name,
          reg_no: invoice.buyer_reg_no,
          address: invoice.buyer_address,
          country: invoice.buyer_country.name,
          phone: invoice.buyer_phone,
          url: invoice.buyer_url,
          email: invoice.buyer_email,
        }
      end

      def items
        invoice.items.map do |item|
          { description: item.description, unit: item.unit,
            quantity: item.quantity, price: item.price,
            sum_without_vat: item.item_sum_without_vat,
            vat_amount: item.vat_amount, total: item.total }
        end
      end

      def simple_object
        {
          id: invoice.id,
          number: invoice.number,
          paid: invoice.paid?,
          payable: invoice.payable?,
          payment_link: invoice.payment_link,
          receipt_date: invoice.receipt_date,
          cancelled: invoice.cancelled?,
          cancellable: invoice.cancellable?,
          due_date: invoice.due_date,
          total: invoice.total,
          recipient: invoice.buyer.billing_email,
        }
      end
    end
  end
end
