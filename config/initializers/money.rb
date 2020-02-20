MoneyRails.configure do |config|
  # Wrapper for Money#default_currency with additional functionality
  config.default_currency = :eur
  config.rounding_mode = BigDecimal::ROUND_HALF_EVEN
  config.locale_backend = :i18n
end
