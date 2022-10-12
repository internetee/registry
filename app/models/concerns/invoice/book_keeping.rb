module Invoice::BookKeeping
  extend ActiveSupport::Concern

  def as_directo_json
    invoice = ActiveSupport::JSON.decode(ActiveSupport::JSON.encode(self))
    invoice['customer'] = compose_directo_customer
    invoice['date'] = issue_date.strftime('%Y-%m-%d')
    invoice['issue_date'] = issue_date.strftime('%Y-%m-%d')
    invoice['transaction_date'] = account_activity
                                  .bank_transaction&.paid_at&.strftime('%Y-%m-%d')
    invoice['language'] = buyer.language == 'en' ? 'ENG' : ''
    invoice['invoice_lines'] = compose_directo_product

    invoice
  end

  def as_monthly_directo_json
    invoice = as_json(only: %i[issue_date due_date created_at
                               vat_rate description number currency])
    invoice['customer'] = compose_directo_customer
    invoice['date'] = issue_date.strftime('%Y-%m-%d')
    invoice['language'] = buyer.language == 'en' ? 'ENG' : ''
    invoice['invoice_lines'] = compose_monthly_directo_lines

    invoice
  end

  private

  def compose_monthly_directo_lines(lines: [])
    metadata['items'].each do |item|
      quantity = item['quantity']
      duration = item['duration_in_years']
      lines << item and next if !quantity || quantity&.negative?

      divide_by_quantity_and_years(quantity, duration, item, lines)
    end
    lines.as_json
  end

  # rubocop:disable Metrics/MethodLength
  def divide_by_quantity_and_years(quantity, duration, item, lines)
    quantity.times do
      single_item = item.except('duration_in_years').merge('quantity' => 1)
      lines << single_item and next if duration < 1

      duration.times do |dur|
        single_item_dup = single_item.dup
        single_item_dup['start_date'] = (issue_date + dur.year).end_of_month.strftime('%Y-%m-%d')
        single_item_dup['end_date'] = (issue_date + (dur + 1).year).end_of_month.strftime('%Y-%m-%d')
        single_item_dup['price'] = (item['price'].to_f / duration).round(2)
        lines << single_item_dup
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def compose_directo_product
    [{ 'product_id': Setting.directo_receipt_product_name, 'description': order,
       'quantity': 1, 'price': ActionController::Base.helpers.number_with_precision(
         subtotal, precision: 2, separator: '.'
       ) }].as_json
  end

  def compose_directo_customer
    {
      'code': buyer.accounting_customer_code,
      'destination': buyer_country_code,
      'vat_reg_no': buyer_vat_no,
    }.as_json
  end
end
