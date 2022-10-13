module Registrar::BookKeeping
  extend ActiveSupport::Concern

  DOMAIN_TO_PRODUCT = { 'ee': '01EE', 'com.ee': '02COM', 'pri.ee': '03PRI',
                        'fie.ee': '04FIE', 'med.ee': '05MED' }.freeze

  included do
    scope :with_cash_accounts, (lambda do
      joins(:accounts).where('accounts.account_type = ? AND test_registrar != ?',
                             Account::CASH,
                             true)
    end)
  end

  def monthly_summary(month:)
    invoice_lines = prepare_invoice_lines(month: month)
    return unless invoice_lines

    invoice = {
      'date': month.end_of_month.strftime('%Y-%m-%d'),
      'description': title_for_summary(month),
    }.as_json
    invoice['invoice_lines'] = invoice_lines
    invoice
  end

  def prepare_invoice_lines(month:, lines: [])
    activities = monthly_activities(month)
    return if activities.empty?

    activities.each do |activity|
      lines << new_monthly_invoice_line(activity)
    end
    lines.sort_by! { |k, _v| k['product_id'] }
    lines.sort_by! { |k, _v| k['duration_in_years'] }
    lines.unshift({ 'description': title_for_summary(month) })
    lines << prepayment_for_all(lines)
    lines.as_json
  end

  def find_or_init_monthly_invoice(month:)
    invoice = invoices.find_by(monthly_invoice: true, issue_date: month.end_of_month.to_date,
                               cancelled_at: nil)
    return invoice if invoice

    summary = monthly_summary(month: month)
    return unless summary

    init_monthly_invoice(summary)
  end

  def title_for_summary(date)
    I18n.with_locale(language == 'en' ? 'en' : 'et') do
      I18n.t('registrar.monthly_summary_title', date: I18n.l(date, format: '%B %Y'))
    end
  end

  def monthly_activities(month)
    AccountActivity.where(account_id: account_ids)
                   .where(created_at: month.beginning_of_month..month.end_of_month)
                   .where(activity_type: [AccountActivity::CREATE, AccountActivity::RENEW])
  end

  def new_monthly_invoice_line(activity)
    price = load_price(activity)
    duration = price.duration.in_years.to_i
    {
      'product_id': DOMAIN_TO_PRODUCT[price.zone_name.to_sym],
      'quantity': 1,
      'unit': language == 'en' ? 'pc' : 'tk',
      'price': price.price.amount.to_f,
      'duration_in_years': duration,
      'description': description_in_language(price: price, yearly: duration >= 1),
    }.with_indifferent_access
  end

  def description_in_language(price:, yearly:)
    timeframe_string = yearly ? 'yearly' : 'monthly'
    locale_string = "registrar.invoice_#{timeframe_string}_product_description"
    length = yearly ? price.duration.in_years.to_i : price.duration.in_months.to_i

    I18n.with_locale(language == 'en' ? 'en' : 'et') do
      I18n.t(locale_string, tld: ".#{price.zone_name}", length: length)
    end
  end

  def prepayment_for_all(lines)
    total = 0
    en = language == 'en'
    lines.each { |l| total += l['quantity'].to_f * l['price'].to_f }
    {
      'product_id': Setting.directo_receipt_product_name,
      'description': en ? 'Domains prepayment' : 'Domeenide ettemaks',
      'quantity': -1,
      'price': total,
      'unit': en ? 'pc' : 'tk',
    }
  end

  def load_price(account_activity)
    @pricelists ||= {}
    return @pricelists[account_activity.price_id] if @pricelists.key? account_activity.price_id

    @pricelists[account_activity.price_id] = account_activity.price
  end
end
