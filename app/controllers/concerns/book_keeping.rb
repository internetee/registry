module BookKeeping
  extend ActiveSupport::Concern

  DOMAIN_TO_PRODUCT = { 'ee': '01EE', 'com.ee': '02COM', 'pri.ee': '03PRI',
                        'fie.ee': '04FIE', 'med.ee': '05MED' }.freeze

  def monthly_summary(month:)
    activities = monthly_activites(month)
    return unless activities.any?

    inv = {
      'number': 1,
      'customer_code': accounting_customer_code,
      'language': language, 'currency': activities.first.currency,
      'date': month.end_of_month.strftime('%Y-%m-%d')
    }.as_json

    inv['invoice_lines'] = prepare_invoice_lines(month: month, activities: activities)

    inv
  end

  def prepare_invoice_lines(month:, activities:)
    lines = []

    lines << { 'description': title_for_summary(month) }
    activities.each do |activity|
      fetch_invoice_lines(activity, lines)
    end
    lines << prepayment_for_all(lines)

    lines.as_json
  end

  def title_for_summary(date)
    if language == 'en'
      I18n.with_locale('en') do
        "Domains registrations -  #{I18n.l(date, format: '%B %Y')}"
      end
    else
      I18n.with_locale('et') do
        "Domeenide registreerimine - #{I18n.l(date, format: '%B %Y')}"
      end
    end
  end

  def fetch_invoice_lines(activity, lines)
    price = load_price(activity)
    if price.duration.include? 'year'
      price.duration.to_i.times do |duration|
        lines << new_monthly_invoice_line(activity: activity, duration: duration + 1).as_json
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

  def new_monthly_invoice_line(activity:, duration: nil)
    price = load_price(activity)
    line = {
      'product_id': DOMAIN_TO_PRODUCT[price.zone_name.to_sym],
      'quantity': 1,
      'unit': language == 'en' ? 'pc' : 'tk',
    }

    finalize_invoice_line(line, price: price, duration: duration, activity: activity)
  end

  def finalize_invoice_line(line, price:, activity:, duration:)
    yearly = price.duration.include?('year')

    line['price'] = yearly ? (price.price.amount / price.duration.to_i) : price.price.amount
    line['description'] = description_in_language(price: price, yearly: yearly)

    if duration.present?
      add_product_timeframe(line: line, activity: activity, duration: duration) if duration > 1
    end

    line
  end

  def add_product_timeframe(line:, activity:, duration:)
    create_time = activity.created_at
    line['start_date'] = (create_time + (duration - 1).year).end_of_month.strftime('%Y-%m-%d')
    line['end_date'] = (create_time + (duration - 1).year + 1).end_of_month.strftime('%Y-%m-%d')
  end

  def description_in_language(price:, yearly:)
    en = language == 'en'
    registration_length = if yearly
                            en ? 'year(s)' : 'aasta(t)'
                          else
                            en ? 'month(s)' : 'kuu(d)'
                          end

    registration = en ? 'registration' : 'registreerimine'
    ".#{price.zone_name} #{registration}: #{price.duration.to_i} #{registration_length}"
  end

  def prepayment_for_all(lines)
    total = 0
    lines.each { |l| total += l['quantity'].to_f * l['price'].to_f }
    {
      'product_id': Setting.directo_receipt_product_name,
      'description': language == 'en' ? 'Domains prepayment' : 'Domeenide ettemaks',
      'quantity': -1,
      'price': total,
      'unit': language == 'en' ? 'pc' : 'tk',
    }
  end

  def load_price(account_activity)
    @pricelists ||= {}
    return @pricelists[account_activity.price_id] if @pricelists.key? account_activity.price_id

    @pricelists[account_activity.price_id] = account_activity.price
  end
end
