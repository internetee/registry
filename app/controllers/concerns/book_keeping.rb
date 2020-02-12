module BookKeeping
  extend ActiveSupport::Concern

  DOMAIN_TO_PRODUCT = { 'ee': '01EE', 'com.ee': '02COM', 'pri.ee': '03PRI',
                        'fie.ee': '04FIE', 'med.ee': '05MED' }.freeze

  def monthly_summary(month:)
    activities = monthly_activites(month)
    inv = {
      'number': 1,
      'customer_code': accounting_customer_code,
      'language': language,
      'currency': activities.first.currency,
      'date': month.end_of_month.strftime('%Y-%m-%d'),
    }.as_json

    lines = []
    activities.each do |activity|
      fetch_invoice_lines(activity, lines)
    end
    lines << prepayment_for_all(lines)

    inv['invoice_lines'] = lines.as_json

    inv
  end

  def fetch_invoice_lines(activity, lines)
    price = load_price(activity)
    if price.duration.include? 'year'
      price.duration.to_i.times do |duration|
        lines << new_montly_invoice_line(activity: activity, duration: duration + 1).as_json
      end
    else
      lines << new_monthly_invoice_line(activity: activity).as_json
    end
  end

  def monthly_activites(month)
    AccountActivity.where(account_id: account_ids)
                   .where(created_at: month.beginning_of_month..month.end_of_month)
                   .where(activity_type: [AccountActivity::CREATE, AccountActivity::RENEW])
  end

  def new_montly_invoice_line(activity:, duration: nil)
    price = DirectoInvoiceForwardJob.load_price(activity)
    yearly = price.duration.include?('year')
    line = {
      'product_id': DOMAIN_TO_PRODUCT[price.zone_name.to_sym],
      'quantity': 1,
      'price': yearly ? (price.price.amount / price.duration.to_i) : price.amount,
    }

    line['description'] = description_in_language(price: price, yearly: yearly)
    add_product_timeframe(line: line, activity: activity, duration: duration) if duration > 1

    line
  end

  def add_product_timeframe(line:, activity:, duration:)
    create_time = activity.created_at
    line['start_date'] = (create_time + (duration - 1).year).end_of_month.strftime('%Y-%m-%d')
    line['end_date'] = (create_time + (duration - 1).year + 1).end_of_month.strftime('%Y-%m-%d')
  end

  def description_in_language(price:, yearly:)
    if language == 'en'
      registration_length = yearly ? 'year' : 'month'
      prefix = ".#{price.zone_name} registration: #{price.duration.to_i} #{registration_length}"
      suffix = 's'
    else
      registration_length = yearly ? 'aasta' : 'kuu'
      prefix = ".#{price.zone_name} registreerimine: #{price.duration.to_i} #{registration_length}"
      suffix = yearly ? 't' : 'd'
    end

    return "#{prefix}#{suffix}" if price.duration.to_i > 1

    prefix
  end

  def prepayment_for_all(lines)
    total = 0
    lines.each { |l| total += l['quantity'].to_f * l['price'].to_f }
    {
      'product_id': Setting.directo_receipt_product_name,
      'description': 'Domeenide ettemaks',
      'quantity': -1,
      'price': total
    }
  end

  def load_price(account_activity)
    @pricelists ||= {}
    return @pricelists[account_activity.price_id] if @pricelists.key? account_activity.price_id

    @pricelists[account_activity.price_id] = account_activity.price
  end
end
